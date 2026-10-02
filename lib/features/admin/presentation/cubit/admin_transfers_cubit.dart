import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../../../../data/repositories/airport_transfer_repository.dart';
import 'admin_transfers_state.dart';

class AdminTransfersCubit extends Cubit<AdminTransfersState> {
  final AirportTransferRepository _transferRepository;

  AdminTransfersCubit({required AirportTransferRepository transferRepository})
      : _transferRepository = transferRepository,
        super(const AdminTransfersState());

  Future<void> loadAllData() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final vehicles = await _transferRepository.getTransferVehicles(activeOnly: false);
      final bookings = await _transferRepository.getTransferBookings();

      final filteredV = _applyVehicleFilters(vehicles, state.vehicleSearchQuery, state.vehicleTypeFilter);
      final filteredB = _applyBookingFilters(bookings, state.bookingSearchQuery, state.bookingStatusFilter);

      emit(state.copyWith(
        isLoading: false,
        allVehicles: vehicles,
        filteredVehicles: filteredV,
        allBookings: bookings,
        filteredBookings: filteredB,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transfer data: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  // ── Vehicle Management ─────────────────────────────────────────────────────

  void searchVehicles(String query) {
    final filtered = _applyVehicleFilters(state.allVehicles, query, state.vehicleTypeFilter);
    emit(state.copyWith(vehicleSearchQuery: query, filteredVehicles: filtered));
  }

  void filterVehicleType(String type) {
    final filtered = _applyVehicleFilters(state.allVehicles, state.vehicleSearchQuery, type);
    emit(state.copyWith(vehicleTypeFilter: type, filteredVehicles: filtered));
  }

  Future<bool> saveVehicle(TransferVehicleModel vehicle) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      if (vehicle.id.isEmpty) {
        final created = await _transferRepository.createTransferVehicle(vehicle);
        final updatedList = [created, ...state.allVehicles];
        final filtered = _applyVehicleFilters(updatedList, state.vehicleSearchQuery, state.vehicleTypeFilter);
        emit(state.copyWith(
          isSaving: false,
          allVehicles: updatedList,
          filteredVehicles: filtered,
          successMessage: 'Vehicle added successfully!',
        ));
      } else {
        final updated = await _transferRepository.updateTransferVehicle(vehicle);
        final updatedList = state.allVehicles.map((v) => v.id == updated.id ? updated : v).toList();
        final filtered = _applyVehicleFilters(updatedList, state.vehicleSearchQuery, state.vehicleTypeFilter);
        emit(state.copyWith(
          isSaving: false,
          allVehicles: updatedList,
          filteredVehicles: filtered,
          successMessage: 'Vehicle updated successfully!',
        ));
      }
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save vehicle: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleVehicleStatus(TransferVehicleModel vehicle) async {
    final updated = vehicle.copyWith(active: !vehicle.active);
    await saveVehicle(updated);
  }

  Future<bool> deleteVehicle(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _transferRepository.deleteTransferVehicle(id);
      final updatedList = state.allVehicles.where((v) => v.id != id).toList();
      final filtered = _applyVehicleFilters(updatedList, state.vehicleSearchQuery, state.vehicleTypeFilter);
      emit(state.copyWith(
        isSaving: false,
        allVehicles: updatedList,
        filteredVehicles: filtered,
        successMessage: 'Vehicle deleted successfully!',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete vehicle: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  // ── Booking Requests Management ────────────────────────────────────────────

  void searchBookings(String query) {
    final filtered = _applyBookingFilters(state.allBookings, query, state.bookingStatusFilter);
    emit(state.copyWith(bookingSearchQuery: query, filteredBookings: filtered));
  }

  void filterBookingStatus(TransferStatus? status) {
    final filtered = _applyBookingFilters(state.allBookings, state.bookingSearchQuery, status);
    emit(state.copyWith(
      bookingStatusFilter: status,
      clearStatusFilter: status == null,
      filteredBookings: filtered,
    ));
  }

  Future<bool> updateBookingStatus(String bookingId, TransferStatus newStatus) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _transferRepository.updateTransferBookingStatus(bookingId, newStatus);
      final updatedList = state.allBookings.map((b) => b.id == bookingId ? updated : b).toList();
      final filtered = _applyBookingFilters(updatedList, state.bookingSearchQuery, state.bookingStatusFilter);
      emit(state.copyWith(
        isSaving: false,
        allBookings: updatedList,
        filteredBookings: filtered,
        successMessage: 'Booking status updated to ${newStatus.label}!',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update status: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteBooking(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _transferRepository.deleteTransferBooking(id);
      final updatedList = state.allBookings.where((b) => b.id != id).toList();
      final filtered = _applyBookingFilters(updatedList, state.bookingSearchQuery, state.bookingStatusFilter);
      emit(state.copyWith(
        isSaving: false,
        allBookings: updatedList,
        filteredBookings: filtered,
        successMessage: 'Booking request deleted successfully!',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete booking: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  // ── Private Filters Helpers ────────────────────────────────────────────────

  List<TransferVehicleModel> _applyVehicleFilters(
    List<TransferVehicleModel> list,
    String query,
    String typeFilter,
  ) {
    return list.where((v) {
      if (typeFilter != 'all' && !v.vehicleType.toLowerCase().contains(typeFilter.toLowerCase())) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = v.vehicleName.toLowerCase().contains(q) ||
            (v.vehicleNameAr?.toLowerCase().contains(q) ?? false);
        final matchType = v.vehicleType.toLowerCase().contains(q);
        if (!matchName && !matchType) return false;
      }
      return true;
    }).toList();
  }

  List<TransferBookingModel> _applyBookingFilters(
    List<TransferBookingModel> list,
    String query,
    TransferStatus? statusFilter,
  ) {
    return list.where((b) {
      if (statusFilter != null && b.status != statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = b.customerName.toLowerCase().contains(q);
        final matchEmail = b.email.toLowerCase().contains(q);
        final matchPhone = b.phone.toLowerCase().contains(q);
        final matchLocations = b.pickupLocation.toLowerCase().contains(q) ||
            b.dropoffLocation.toLowerCase().contains(q);
        final matchRef = b.id.toLowerCase().contains(q);
        if (!matchName && !matchEmail && !matchPhone && !matchLocations && !matchRef) return false;
      }
      return true;
    }).toList();
  }
}
