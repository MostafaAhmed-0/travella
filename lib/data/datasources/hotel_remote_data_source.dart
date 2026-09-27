import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../services/supabase_service.dart';

abstract class HotelRemoteDataSource {
  Future<List<HotelModel>> getHotels({bool? featuredOnly, bool activeOnly = true});
  Future<HotelModel?> getHotelById(String id);
  Future<HotelModel> createHotel(HotelModel hotel);
  Future<HotelModel> updateHotel(HotelModel hotel);
  Future<void> deleteHotel(String id);
}

class HotelRemoteDataSourceImpl implements HotelRemoteDataSource {
  final SupabaseClient _client;

  HotelRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<HotelModel>> getHotels({bool? featuredOnly, bool activeOnly = true}) async {
    try {
      var query = _client.from(SupabaseService.tableHotels).select();
      if (activeOnly) {
        query = query.eq('active', true);
      }
      if (featuredOnly == true) {
        query = query.eq('featured', true);
      }
      final response = await query.order('rating', ascending: false);
      return (response as List)
          .map((json) => HotelModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<HotelModel?> getHotelById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableHotels)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return HotelModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<HotelModel> createHotel(HotelModel hotel) async {
    try {
      final map = hotel.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableHotels)
          .insert(map)
          .select()
          .single();
      return HotelModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<HotelModel> updateHotel(HotelModel hotel) async {
    try {
      final map = hotel.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableHotels)
          .update(map)
          .eq('id', hotel.id)
          .select()
          .single();
      return HotelModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteHotel(String id) async {
    try {
      await _client.from(SupabaseService.tableHotels).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
