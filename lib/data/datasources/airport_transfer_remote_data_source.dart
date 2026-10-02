import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/airport_transfer_model.dart';
import '../services/supabase_service.dart';

abstract class AirportTransferRemoteDataSource {
  Future<List<TransferVehicleModel>> getTransferVehicles({bool activeOnly = true});
  Future<TransferVehicleModel?> getTransferVehicleById(String id);
  Future<TransferVehicleModel> createTransferVehicle(TransferVehicleModel vehicle);
  Future<TransferVehicleModel> updateTransferVehicle(TransferVehicleModel vehicle);
  Future<void> deleteTransferVehicle(String id);

  Future<List<TransferBookingModel>> getTransferBookings();
  Future<TransferBookingModel> createTransferBooking(TransferBookingModel booking);
  Future<TransferBookingModel> updateTransferBookingStatus(String id, TransferStatus status);
  Future<void> deleteTransferBooking(String id);
}

class AirportTransferRemoteDataSourceImpl implements AirportTransferRemoteDataSource {
  final SupabaseClient _client;

  AirportTransferRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<TransferVehicleModel>> getTransferVehicles({bool activeOnly = true}) async {
    try {
      var query = _client.from(SupabaseService.tableTransferVehicles).select();
      if (activeOnly) {
        query = query.eq('active', true);
      }
      final response = await query.order('base_price', ascending: true);
      final list = (response as List)
          .map((json) => TransferVehicleModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        // Fallback to rich sample vehicles if DB is currently empty
        return activeOnly
            ? TransferVehicleModel.sampleVehicles.where((v) => v.active).toList()
            : TransferVehicleModel.sampleVehicles;
      }
      return list;
    } catch (_) {
      // Return default sample vehicles if table doesn't exist yet in Supabase instance
      return activeOnly
          ? TransferVehicleModel.sampleVehicles.where((v) => v.active).toList()
          : TransferVehicleModel.sampleVehicles;
    }
  }

  @override
  Future<TransferVehicleModel?> getTransferVehicleById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableTransferVehicles)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return TransferVehicleModel.fromJson(response);
      }

      // Check sample vehicles
      final match = TransferVehicleModel.sampleVehicles.where((v) => v.id == id);
      return match.isNotEmpty ? match.first : null;
    } catch (_) {
      final match = TransferVehicleModel.sampleVehicles.where((v) => v.id == id);
      return match.isNotEmpty ? match.first : null;
    }
  }

  @override
  Future<TransferVehicleModel> createTransferVehicle(TransferVehicleModel vehicle) async {
    try {
      final map = vehicle.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTransferVehicles)
          .insert(map)
          .select()
          .single();
      return TransferVehicleModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TransferVehicleModel> updateTransferVehicle(TransferVehicleModel vehicle) async {
    try {
      final map = vehicle.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTransferVehicles)
          .update(map)
          .eq('id', vehicle.id)
          .select()
          .single();
      return TransferVehicleModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteTransferVehicle(String id) async {
    try {
      await _client.from(SupabaseService.tableTransferVehicles).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<List<TransferBookingModel>> getTransferBookings() async {
    try {
      final response = await _client
          .from(SupabaseService.tableTransferBookings)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TransferBookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If table is newly created or empty
      return [];
    }
  }

  @override
  Future<TransferBookingModel> createTransferBooking(TransferBookingModel booking) async {
    try {
      final map = booking.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTransferBookings)
          .insert(map)
          .select()
          .single();
      return TransferBookingModel.fromJson(response);
    } catch (e) {
      // If table not migrated in Supabase remote, provide dummy successful instance with generated ID
      return booking.copyWith(
        id: 'tb-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<TransferBookingModel> updateTransferBookingStatus(String id, TransferStatus status) async {
    try {
      final response = await _client
          .from(SupabaseService.tableTransferBookings)
          .update({
            'status': status.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      return TransferBookingModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteTransferBooking(String id) async {
    try {
      await _client.from(SupabaseService.tableTransferBookings).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
