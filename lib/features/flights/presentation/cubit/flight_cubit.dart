import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../data/models/flight_models.dart';
import 'flight_state.dart';

class FlightCubit extends Cubit<FlightState> {
  final BookingRepository _bookingRepository;

  FlightCubit({required BookingRepository bookingRepository, FlightSearchQuery? initialQuery})
      : _bookingRepository = bookingRepository,
        super(FlightInitial(query: initialQuery ?? FlightSearchQuery.defaultQuery()));

  /// Perform flight search with given query parameters
  Future<void> searchFlights(FlightSearchQuery query) async {
    emit(const FlightLoading(message: 'Searching verified routes & partner schedules...'));

    try {
      // Simulate realistic async query lookup
      await Future.delayed(const Duration(milliseconds: 400));

      final allOffers = FlightOfferCatalog.getOffersForQuery(query);

      if (allOffers.isEmpty) {
        emit(FlightNoResults(
          query: query,
          filters: FlightFilterState.defaultState,
          reason: 'No airline schedules found for the selected route. Submit an inquiry for bespoke charter or offline routing.',
        ));
        return;
      }

      final airlines = allOffers.map((e) => e.airlineName).toSet();
      final minPrice = allOffers.map((e) => e.price).reduce((a, b) => a < b ? a : b);
      final maxPrice = allOffers.map((e) => e.price).reduce((a, b) => a > b ? a : b);

      final filterState = FlightFilterState(
        maxPrice: (maxPrice * 1.5).ceilToDouble(),
      );

      final filtered = _applyFilters(allOffers, filterState);

      emit(FlightLoaded(
        query: query,
        allOffers: allOffers,
        filteredOffers: filtered,
        filters: filterState,
        availableAirlines: airlines,
        minFoundPrice: minPrice,
        maxFoundPrice: maxPrice,
      ));
    } catch (e) {
      emit(FlightError(
        message: 'Unable to load flight options: ${e.toString().replaceAll('Exception: ', '')}',
        query: query,
      ));
    }
  }

  /// Update active filters on current results
  void updateFilters(FlightFilterState newFilters) {
    if (state is! FlightLoaded) return;
    final currentState = state as FlightLoaded;

    final filtered = _applyFilters(currentState.allOffers, newFilters);

    if (filtered.isEmpty) {
      emit(FlightNoResults(
        query: currentState.query,
        filters: newFilters,
        reason: 'No flights match your filter criteria. Try adjusting your stops, airlines, or time range.',
      ));
    } else {
      emit(currentState.copyWith(
        filteredOffers: filtered,
        filters: newFilters,
      ));
    }
  }

  /// Reset all filters to default
  void resetFilters() {
    if (state is FlightLoaded) {
      final currentState = state as FlightLoaded;
      final defaultFilter = FlightFilterState(
        maxPrice: (currentState.maxFoundPrice * 1.5).ceilToDouble(),
      );
      final filtered = _applyFilters(currentState.allOffers, defaultFilter);
      emit(currentState.copyWith(
        filters: defaultFilter,
        filteredOffers: filtered,
      ));
    } else if (state is FlightNoResults) {
      final currentState = state as FlightNoResults;
      searchFlights(currentState.query);
    }
  }

  /// Filter & Sort calculation logic
  List<FlightOffer> _applyFilters(List<FlightOffer> source, FlightFilterState filters) {
    var list = List<FlightOffer>.from(source);

    // Stops filter
    if (filters.stops == FlightStopsFilter.nonStop) {
      list = list.where((f) => f.stopsCount == 0).toList();
    } else if (filters.stops == FlightStopsFilter.oneStop) {
      list = list.where((f) => f.stopsCount == 1).toList();
    } else if (filters.stops == FlightStopsFilter.twoPlusStops) {
      list = list.where((f) => f.stopsCount >= 2).toList();
    }

    // Airline filter
    if (filters.selectedAirlines.isNotEmpty) {
      list = list.where((f) => filters.selectedAirlines.contains(f.airlineName)).toList();
    }

    // Departure Time slot
    if (filters.departureSlot != FlightTimeSlot.any) {
      list = list.where((f) => _matchesSlot(f.departureHour, filters.departureSlot)).toList();
    }

    // Arrival Time slot
    if (filters.arrivalSlot != FlightTimeSlot.any) {
      list = list.where((f) => _matchesSlot(f.arrivalHour, filters.arrivalSlot)).toList();
    }

    // Price Range filter
    list = list.where((f) => f.price <= filters.maxPrice).toList();

    // Duration filter
    list = list.where((f) => f.durationHours <= filters.maxDurationHours).toList();

    // Sort By
    if (filters.sortBy == 'Price: Low to High' || filters.sortBy == 'Lowest Price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (filters.sortBy == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (filters.sortBy == 'Shortest Duration' || filters.sortBy == 'Duration') {
      list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    } else if (filters.sortBy == 'Earliest Departure' || filters.sortBy == 'Departure') {
      list.sort((a, b) => a.departureHour.compareTo(b.departureHour));
    }

    return list;
  }

  bool _matchesSlot(int hour, FlightTimeSlot slot) {
    switch (slot) {
      case FlightTimeSlot.earlyMorning:
        return hour >= 0 && hour < 6;
      case FlightTimeSlot.morning:
        return hour >= 6 && hour < 12;
      case FlightTimeSlot.afternoon:
        return hour >= 12 && hour < 18;
      case FlightTimeSlot.evening:
        return hour >= 18 && hour < 24;
      case FlightTimeSlot.any:
        return true;
    }
  }

  /// Submit Flight Inquiry to Supabase (Requirements 6 & 7)
  Future<bool> submitFlightInquiry({
    required FlightSearchQuery query,
    required String customerName,
    required String email,
    required String phone,
    String? preferredAirline,
    String? userNotes,
    bool directOnly = false,
    bool flexibleDates = false,
    FlightOffer? selectedOffer,
  }) async {
    emit(const FlightLoading(message: 'Saving your flight inquiry with Travella air desk...'));

    try {
      final cleanName = customerName.trim();
      final cleanEmail = email.trim();
      final cleanPhone = phone.trim();

      if (cleanName.isEmpty) throw Exception('Customer full name is required.');
      if (cleanEmail.isEmpty) throw Exception('Email address is required.');
      if (cleanPhone.isEmpty) throw Exception('Phone number is required.');

      final df = DateFormat('EEE, dd MMM yyyy');
      final tripTypeStr = query.isRoundTrip ? 'Round Trip' : 'One Way';
      final returnStr = query.isRoundTrip && query.returnDate != null
          ? ' | Return: ${df.format(query.returnDate!)}'
          : '';
      final childAgesStr = query.childAges.isNotEmpty
          ? ' [Child Ages: ${query.childAges.join(', ')}]'
          : '';

      final structuredNotes = StringBuffer()
        ..writeln('=== VERIFIED FLIGHT INQUIRY & RESERVATION ===')
        ..writeln('Route: ${query.origin} ➔ ${query.destination}')
        ..writeln('Trip Type: $tripTypeStr')
        ..writeln('Departure: ${df.format(query.departureDate)}$returnStr')
        ..writeln('Cabin Class: ${query.cabinClass}')
        ..writeln('Travelers: ${query.adults} Adults, ${query.children} Children$childAgesStr')
        ..writeln('Direct Only Preference: ${directOnly ? 'Yes' : 'No'}')
        ..writeln('Flexible Dates (+/- 3 days): ${flexibleDates ? 'Yes' : 'No'}');

      if (selectedOffer != null) {
        structuredNotes.writeln('Selected Itinerary: ${selectedOffer.airlineName} (${selectedOffer.flightNumber}) - Estimated ${selectedOffer.currency} ${selectedOffer.price.toInt()}');
      }
      if (preferredAirline != null && preferredAirline.trim().isNotEmpty) {
        structuredNotes.writeln('Preferred Airline: ${preferredAirline.trim()}');
      }
      if (userNotes != null && userNotes.trim().isNotEmpty) {
        structuredNotes.writeln('Special Instructions: ${userNotes.trim()}');
      }

      final bookingModel = BookingModel(
        id: '',
        customerName: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        travelDate: query.departureDate,
        travelers: query.totalTravelers,
        adultsCount: query.adults,
        childrenCount: query.children,
        childrenAges: query.childAges,
        status: BookingStatus.pending,
        notes: structuredNotes.toString(),
      );

      final savedBooking = await _bookingRepository.createBooking(bookingModel);
      final refCode = savedBooking.bookingReference;

      emit(FlightInquirySubmitted(
        booking: savedBooking,
        query: query,
        selectedOffer: selectedOffer,
        referenceCode: refCode,
      ));

      return true;
    } catch (e) {
      emit(FlightError(
        message: 'Failed to submit flight inquiry: ${e.toString().replaceAll('Exception: ', '')}',
        query: query,
      ));
      return false;
    }
  }

  /// Return to initial state or fresh search
  void resetToInitial() {
    emit(FlightInitial(query: FlightSearchQuery.defaultQuery()));
  }
}
