import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination_model.dart';
import '../services/supabase_service.dart';

abstract class DestinationRemoteDataSource {
  Future<List<DestinationModel>> getDestinations({bool? featuredOnly});
  Future<DestinationModel?> getDestinationById(String id);
  Future<DestinationModel> createDestination(DestinationModel destination);
  Future<DestinationModel> updateDestination(DestinationModel destination);
  Future<void> deleteDestination(String id);
}

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  final SupabaseClient _client;

  DestinationRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<DestinationModel>> getDestinations({bool? featuredOnly}) async {
    try {
      var query = _client.from(SupabaseService.tableDestinations).select();
      if (featuredOnly == true) {
        query = query.eq('featured', true);
      }
      final response = await query.order('name');
      return (response as List)
          .map((json) => DestinationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<DestinationModel?> getDestinationById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableDestinations)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return DestinationModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<DestinationModel> createDestination(DestinationModel destination) async {
    try {
      final map = destination.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableDestinations)
          .insert(map)
          .select()
          .single();
      return DestinationModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<DestinationModel> updateDestination(DestinationModel destination) async {
    try {
      final map = destination.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableDestinations)
          .update(map)
          .eq('id', destination.id)
          .select()
          .single();
      return DestinationModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteDestination(String id) async {
    try {
      await _client
          .from(SupabaseService.tableDestinations)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
