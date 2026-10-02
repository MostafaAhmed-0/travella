import 'package:equatable/equatable.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../data/models/airport_transfer_model.dart';

class TransfersState extends Equatable {
  final bool isLoading;
  final bool isBooking;
  final String? errorMessage;
  final String? bookingSuccessId;
  final TransferBookingModel? lastCreatedBooking;

  // Search parameters
  final TransferType transferType;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupDate;
  final String pickupTime;
  final TravelerSelection passengers;
  final int luggageCount;
  final String selectedVehicleType; // 'all' or 'sedan', 'suv', 'van', 'minibus', etc.
  final double maxPrice;
  final String sortBy; // 'price_asc', 'price_desc', 'capacity_desc'

  // Data
  final List<TransferVehicleModel> allVehicles;
  final List<TransferVehicleModel> filteredVehicles;

  const TransfersState({
    this.isLoading = false,
    this.isBooking = false,
    this.errorMessage,
    this.bookingSuccessId,
    this.lastCreatedBooking,
    this.transferType = TransferType.airportToHotel,
    this.pickupLocation = 'Cairo International Airport (CAI)',
    this.dropoffLocation = 'Downtown Cairo / Giza Hotels',
    required this.pickupDate,
    this.pickupTime = '12:00 PM',
    this.passengers = const TravelerSelection(adults: 2, children: 0, childAges: []),
    this.luggageCount = 2,
    this.selectedVehicleType = 'all',
    this.maxPrice = 500.0,
    this.sortBy = 'price_asc',
    this.allVehicles = const [],
    this.filteredVehicles = const [],
  });

  TransfersState copyWith({
    bool? isLoading,
    bool? isBooking,
    String? errorMessage,
    String? bookingSuccessId,
    TransferBookingModel? lastCreatedBooking,
    TransferType? transferType,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupDate,
    String? pickupTime,
    TravelerSelection? passengers,
    int? luggageCount,
    String? selectedVehicleType,
    double? maxPrice,
    String? sortBy,
    List<TransferVehicleModel>? allVehicles,
    List<TransferVehicleModel>? filteredVehicles,
    bool clearError = false,
    bool clearBookingSuccess = false,
  }) {
    return TransfersState(
      isLoading: isLoading ?? this.isLoading,
      isBooking: isBooking ?? this.isBooking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bookingSuccessId: clearBookingSuccess ? null : (bookingSuccessId ?? this.bookingSuccessId),
      lastCreatedBooking: clearBookingSuccess ? null : (lastCreatedBooking ?? this.lastCreatedBooking),
      transferType: transferType ?? this.transferType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      passengers: passengers ?? this.passengers,
      luggageCount: luggageCount ?? this.luggageCount,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      allVehicles: allVehicles ?? this.allVehicles,
      filteredVehicles: filteredVehicles ?? this.filteredVehicles,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isBooking,
        errorMessage,
        bookingSuccessId,
        lastCreatedBooking,
        transferType,
        pickupLocation,
        dropoffLocation,
        pickupDate,
        pickupTime,
        passengers,
        luggageCount,
        selectedVehicleType,
        maxPrice,
        sortBy,
        allVehicles,
        filteredVehicles,
      ];
}
