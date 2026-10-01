import 'package:equatable/equatable.dart';
import '../../../../data/models/booking_model.dart';
import '../../data/models/flight_models.dart';

abstract class FlightState extends Equatable {
  const FlightState();

  @override
  List<Object?> get props => [];
}

/// 1. Initial State: When user lands on /flights before searching
class FlightInitial extends FlightState {
  final FlightSearchQuery query;

  const FlightInitial({required this.query});

  @override
  List<Object?> get props => [query];
}

/// 2. Loading State: When searching or processing filters
class FlightLoading extends FlightState {
  final String? message;

  const FlightLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// 3. Results State: Loaded results with query and active filters
class FlightLoaded extends FlightState {
  final FlightSearchQuery query;
  final List<FlightOffer> allOffers;
  final List<FlightOffer> filteredOffers;
  final FlightFilterState filters;
  final Set<String> availableAirlines;
  final double minFoundPrice;
  final double maxFoundPrice;

  const FlightLoaded({
    required this.query,
    required this.allOffers,
    required this.filteredOffers,
    required this.filters,
    required this.availableAirlines,
    required this.minFoundPrice,
    required this.maxFoundPrice,
  });

  @override
  List<Object?> get props => [
        query,
        allOffers,
        filteredOffers,
        filters,
        availableAirlines,
        minFoundPrice,
        maxFoundPrice,
      ];

  FlightLoaded copyWith({
    FlightSearchQuery? query,
    List<FlightOffer>? allOffers,
    List<FlightOffer>? filteredOffers,
    FlightFilterState? filters,
    Set<String>? availableAirlines,
    double? minFoundPrice,
    double? maxFoundPrice,
  }) {
    return FlightLoaded(
      query: query ?? this.query,
      allOffers: allOffers ?? this.allOffers,
      filteredOffers: filteredOffers ?? this.filteredOffers,
      filters: filters ?? this.filters,
      availableAirlines: availableAirlines ?? this.availableAirlines,
      minFoundPrice: minFoundPrice ?? this.minFoundPrice,
      maxFoundPrice: maxFoundPrice ?? this.maxFoundPrice,
    );
  }
}

/// 4. No Results State
class FlightNoResults extends FlightState {
  final FlightSearchQuery query;
  final FlightFilterState filters;
  final String reason;

  const FlightNoResults({
    required this.query,
    required this.filters,
    required this.reason,
  });

  @override
  List<Object?> get props => [query, filters, reason];
}

/// 5. Error State
class FlightError extends FlightState {
  final String message;
  final FlightSearchQuery? query;

  const FlightError({required this.message, this.query});

  @override
  List<Object?> get props => [message, query];
}

/// 6. Inquiry Submitted State (Requirement 6 & 7)
class FlightInquirySubmitted extends FlightState {
  final BookingModel booking;
  final FlightSearchQuery query;
  final FlightOffer? selectedOffer;
  final String referenceCode;

  const FlightInquirySubmitted({
    required this.booking,
    required this.query,
    this.selectedOffer,
    required this.referenceCode,
  });

  @override
  List<Object?> get props => [booking, query, selectedOffer, referenceCode];
}
