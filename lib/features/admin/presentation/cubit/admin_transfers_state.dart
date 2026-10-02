import 'package:equatable/equatable.dart';
import '../../../../data/models/airport_transfer_model.dart';

class AdminTransfersState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  // Vehicles Fleet
  final List<TransferVehicleModel> allVehicles;
  final List<TransferVehicleModel> filteredVehicles;
  final String vehicleSearchQuery;
  final String vehicleTypeFilter;

  // Bookings / Requests
  final List<TransferBookingModel> allBookings;
  final List<TransferBookingModel> filteredBookings;
  final String bookingSearchQuery;
  final TransferStatus? bookingStatusFilter;

  const AdminTransfersState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allVehicles = const [],
    this.filteredVehicles = const [],
    this.vehicleSearchQuery = '',
    this.vehicleTypeFilter = 'all',
    this.allBookings = const [],
    this.filteredBookings = const [],
    this.bookingSearchQuery = '',
    this.bookingStatusFilter,
  });

  AdminTransfersState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<TransferVehicleModel>? allVehicles,
    List<TransferVehicleModel>? filteredVehicles,
    String? vehicleSearchQuery,
    String? vehicleTypeFilter,
    List<TransferBookingModel>? allBookings,
    List<TransferBookingModel>? filteredBookings,
    String? bookingSearchQuery,
    TransferStatus? bookingStatusFilter,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearStatusFilter = false,
  }) {
    return AdminTransfersState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allVehicles: allVehicles ?? this.allVehicles,
      filteredVehicles: filteredVehicles ?? this.filteredVehicles,
      vehicleSearchQuery: vehicleSearchQuery ?? this.vehicleSearchQuery,
      vehicleTypeFilter: vehicleTypeFilter ?? this.vehicleTypeFilter,
      allBookings: allBookings ?? this.allBookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      bookingSearchQuery: bookingSearchQuery ?? this.bookingSearchQuery,
      bookingStatusFilter: clearStatusFilter ? null : (bookingStatusFilter ?? this.bookingStatusFilter),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allVehicles,
        filteredVehicles,
        vehicleSearchQuery,
        vehicleTypeFilter,
        allBookings,
        filteredBookings,
        bookingSearchQuery,
        bookingStatusFilter,
      ];
}
