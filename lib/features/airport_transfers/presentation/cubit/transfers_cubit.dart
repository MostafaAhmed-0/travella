import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../../../../data/repositories/airport_transfer_repository.dart';
import 'transfers_state.dart';

class TransfersCubit extends Cubit<TransfersState> {
  final AirportTransferRepository _transferRepository;

  TransfersCubit({required AirportTransferRepository transferRepository})
      : _transferRepository = transferRepository,
        super(TransfersState(pickupDate: DateTime.now().add(const Duration(days: 1))));

  Future<void> loadVehicles() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final vehicles = await _transferRepository.getTransferVehicles(activeOnly: true);
      final filtered = _filterVehicles(
        vehicles: vehicles,
        type: state.selectedVehicleType,
        passengersCount: state.passengers.totalTravelers,
        luggageCount: state.luggageCount,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        isLoading: false,
        allVehicles: vehicles,
        filteredVehicles: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transfer options: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void updateTransferType(TransferType type) {
    String defaultPickup = state.pickupLocation;
    String defaultDropoff = state.dropoffLocation;

    if (type == TransferType.airportToHotel) {
      defaultPickup = 'Cairo International Airport (CAI)';
      defaultDropoff = 'Downtown Cairo / Giza Hotels';
    } else if (type == TransferType.hotelToAirport) {
      defaultPickup = 'Hotel / City Address';
      defaultDropoff = 'Cairo International Airport (CAI)';
    } else if (type == TransferType.airportToAirport) {
      defaultPickup = 'Cairo Airport (CAI) Terminal 3';
      defaultDropoff = 'Cairo Airport (CAI) Terminal 1 / Sphinx (SPX)';
    }

    emit(state.copyWith(
      transferType: type,
      pickupLocation: defaultPickup,
      dropoffLocation: defaultDropoff,
    ));
    _reapplyFilters();
  }

  void updateSearchLocations({required String pickup, required String dropoff}) {
    emit(state.copyWith(pickupLocation: pickup, dropoffLocation: dropoff));
  }

  void updateDateTime({required DateTime date, required String time}) {
    emit(state.copyWith(pickupDate: date, pickupTime: time));
  }

  void updatePassengers(TravelerSelection selection) {
    emit(state.copyWith(passengers: selection));
    _reapplyFilters();
  }

  void updateLuggage(int luggage) {
    emit(state.copyWith(luggageCount: luggage.clamp(0, 30)));
    _reapplyFilters();
  }

  void updateVehicleTypeFilter(String vehicleType) {
    emit(state.copyWith(selectedVehicleType: vehicleType));
    _reapplyFilters();
  }

  void updateMaxPrice(double price) {
    emit(state.copyWith(maxPrice: price));
    _reapplyFilters();
  }

  void updateSortBy(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
    _reapplyFilters();
  }

  void _reapplyFilters() {
    final filtered = _filterVehicles(
      vehicles: state.allVehicles,
      type: state.selectedVehicleType,
      passengersCount: state.passengers.totalTravelers,
      luggageCount: state.luggageCount,
      maxPrice: state.maxPrice,
      sortBy: state.sortBy,
    );
    emit(state.copyWith(filteredVehicles: filtered));
  }

  List<TransferVehicleModel> _filterVehicles({
    required List<TransferVehicleModel> vehicles,
    required String type,
    required int passengersCount,
    required int luggageCount,
    required double maxPrice,
    required String sortBy,
  }) {
    var result = vehicles.where((v) {
      if (type != 'all' && !v.vehicleType.toLowerCase().contains(type.toLowerCase())) {
        return false;
      }
      if (v.passengerCapacity < passengersCount) {
        return false;
      }
      if (v.luggageCapacity < luggageCount) {
        return false;
      }
      if (v.basePrice > maxPrice) {
        return false;
      }
      return true;
    }).toList();

    // Sorting
    if (sortBy == 'price_asc') {
      result.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (sortBy == 'price_desc') {
      result.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    } else if (sortBy == 'capacity_desc') {
      result.sort((a, b) => b.passengerCapacity.compareTo(a.passengerCapacity));
    }

    return result;
  }

  /// Submit a transfer booking request to Supabase
  Future<bool> createBookingRequest({
    required TransferVehicleModel vehicle,
    required String customerName,
    required String email,
    required String phone,
    String? flightNumber,
    String? specialRequests,
  }) async {
    emit(state.copyWith(isBooking: true, clearError: true, clearBookingSuccess: true));
    try {
      final booking = TransferBookingModel(
        id: '',
        vehicleId: vehicle.id,
        vehicleType: vehicle.vehicleType,
        vehicleName: vehicle.vehicleName,
        transferType: state.transferType,
        pickupLocation: state.pickupLocation,
        dropoffLocation: state.dropoffLocation,
        pickupDate: state.pickupDate,
        pickupTime: state.pickupTime,
        passengersCount: state.passengers.totalTravelers,
        adultsCount: state.passengers.adults,
        childrenCount: state.passengers.children,
        childrenAges: state.passengers.childAges,
        luggageCount: state.luggageCount,
        totalPrice: vehicle.basePrice,
        currency: vehicle.currency,
        customerName: customerName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        flightNumber: flightNumber?.trim(),
        specialRequests: specialRequests?.trim(),
        status: TransferStatus.pending,
      );

      final created = await _transferRepository.createTransferBooking(booking);
      emit(state.copyWith(
        isBooking: false,
        bookingSuccessId: created.id.isNotEmpty ? created.id : 'TB-${DateTime.now().millisecondsSinceEpoch % 100000}',
        lastCreatedBooking: created,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isBooking: false,
        errorMessage: 'Booking submission failed: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  void clearBookingState() {
    emit(state.copyWith(clearBookingSuccess: true, clearError: true));
  }
}
