import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gallery_model.dart';
import '../services/supabase_service.dart';

abstract class GalleryRemoteDataSource {
  Future<List<GalleryModel>> getGalleryItems({String? category, bool? featuredOnly});
  Future<GalleryModel> createGalleryItem(GalleryModel item);
  Future<GalleryModel> updateGalleryItem(GalleryModel item);
  Future<void> deleteGalleryItem(String id);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final SupabaseClient _client;

  GalleryRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<GalleryModel>> getGalleryItems({String? category, bool? featuredOnly}) async {
    try {
      var query = _client.from(SupabaseService.tableGallery).select();
      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      if (featuredOnly == true) {
        query = query.eq('featured', true);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => GalleryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<GalleryModel> createGalleryItem(GalleryModel item) async {
    try {
      final map = item.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableGallery)
          .insert(map)
          .select()
          .single();
      return GalleryModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<GalleryModel> updateGalleryItem(GalleryModel item) async {
    try {
      final map = item.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableGallery)
          .update(map)
          .eq('id', item.id)
          .select()
          .single();
      return GalleryModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteGalleryItem(String id) async {
    try {
      await _client.from(SupabaseService.tableGallery).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
