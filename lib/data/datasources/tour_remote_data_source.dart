import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tour_model.dart';
import '../services/supabase_service.dart';

abstract class TourRemoteDataSource {
  Future<List<TourModel>> getTours({
    TourType? type,
    String? destinationId,
    bool? featuredOnly,
    bool activeOnly = true,
  });

  Future<TourModel?> getTourById(String id);
  Future<TourModel> createTour(TourModel tour);
  Future<TourModel> updateTour(TourModel tour);
  Future<void> deleteTour(String id);
  Future<void> addTourImage(String tourId, String imageUrl, int sortOrder);
  Future<void> deleteTourImage(String imageId);
}

class TourRemoteDataSourceImpl implements TourRemoteDataSource {
  final SupabaseClient _client;

  TourRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<TourModel>> getTours({
    TourType? type,
    String? destinationId,
    bool? featuredOnly,
    bool activeOnly = true,
  }) async {
    try {
      var query = _client
          .from(SupabaseService.tableTours)
          .select('*, tour_images(*)');

      if (activeOnly) {
        query = query.eq('active', true);
      }
      if (type != null) {
        query = query.eq('type', type.toDbString());
      }
      if (destinationId != null) {
        query = query.eq('destination_id', destinationId);
      }
      if (featuredOnly == true) {
        query = query.eq('featured', true);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => TourModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TourModel?> getTourById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableTours)
          .select('*, tour_images(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TourModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TourModel> createTour(TourModel tour) async {
    try {
      final map = tour.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTours)
          .insert(map)
          .select('*, tour_images(*)')
          .single();
      return TourModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TourModel> updateTour(TourModel tour) async {
    try {
      final map = tour.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTours)
          .update(map)
          .eq('id', tour.id)
          .select('*, tour_images(*)')
          .single();
      return TourModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteTour(String id) async {
    try {
      await _client.from(SupabaseService.tableTours).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> addTourImage(String tourId, String imageUrl, int sortOrder) async {
    try {
      await _client.from(SupabaseService.tableTourImages).insert({
        'tour_id': tourId,
        'image_url': imageUrl,
        'sort_order': sortOrder,
      });
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteTourImage(String imageId) async {
    try {
      await _client.from(SupabaseService.tableTourImages).delete().eq('id', imageId);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
