import '../datasources/airport_transfer_remote_data_source.dart';
import '../models/airport_transfer_model.dart';

/// Repository for managing Airport Transfers, vehicle types, and booking requests
class AirportTransferRepository {
  final AirportTransferRemoteDataSource _remoteDataSource;

  AirportTransferRepository({AirportTransferRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AirportTransferRemoteDataSourceImpl();

  /// Retrieve available vehicles / transfer types
  Future<List<TransferVehicleModel>> getTransferVehicles({bool activeOnly = true}) {
    return _remoteDataSource.getTransferVehicles(activeOnly: activeOnly);
  }

  /// Get specific vehicle by ID
  Future<TransferVehicleModel?> getTransferVehicleById(String id) {
    return _remoteDataSource.getTransferVehicleById(id);
  }

  /// Admin: Create transfer vehicle
  Future<TransferVehicleModel> createTransferVehicle(TransferVehicleModel vehicle) {
    return _remoteDataSource.createTransferVehicle(vehicle);
  }

  /// Admin: Update transfer vehicle
  Future<TransferVehicleModel> updateTransferVehicle(TransferVehicleModel vehicle) {
    return _remoteDataSource.updateTransferVehicle(vehicle);
  }

  /// Admin: Delete transfer vehicle
  Future<void> deleteTransferVehicle(String id) {
    return _remoteDataSource.deleteTransferVehicle(id);
  }

  /// Admin: Get list of transfer booking requests
  Future<List<TransferBookingModel>> getTransferBookings() {
    return _remoteDataSource.getTransferBookings();
  }

  /// Customer: Create transfer booking request
  Future<TransferBookingModel> createTransferBooking(TransferBookingModel booking) {
    return _remoteDataSource.createTransferBooking(booking);
  }

  /// Admin: Update booking status
  Future<TransferBookingModel> updateTransferBookingStatus(String id, TransferStatus status) {
    return _remoteDataSource.updateTransferBookingStatus(id, status);
  }

  /// Admin: Delete booking request
  Future<void> deleteTransferBooking(String id) {
    return _remoteDataSource.deleteTransferBooking(id);
  }
}
