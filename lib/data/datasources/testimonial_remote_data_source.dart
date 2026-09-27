import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/testimonial_model.dart';
import '../services/supabase_service.dart';

abstract class TestimonialRemoteDataSource {
  Future<List<TestimonialModel>> getTestimonials({bool activeOnly = true});
  Future<TestimonialModel> createTestimonial(TestimonialModel testimonial);
  Future<TestimonialModel> updateTestimonial(TestimonialModel testimonial);
  Future<void> deleteTestimonial(String id);
}

class TestimonialRemoteDataSourceImpl implements TestimonialRemoteDataSource {
  final SupabaseClient _client;

  TestimonialRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<TestimonialModel>> getTestimonials({bool activeOnly = true}) async {
    try {
      var query = _client.from(SupabaseService.tableTestimonials).select();
      if (activeOnly) {
        query = query.eq('active', true);
      }
      final response = await query.order('rating', ascending: false);
      return (response as List)
          .map((json) => TestimonialModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TestimonialModel> createTestimonial(TestimonialModel testimonial) async {
    try {
      final map = testimonial.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTestimonials)
          .insert(map)
          .select()
          .single();
      return TestimonialModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<TestimonialModel> updateTestimonial(TestimonialModel testimonial) async {
    try {
      final map = testimonial.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableTestimonials)
          .update(map)
          .eq('id', testimonial.id)
          .select()
          .single();
      return TestimonialModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteTestimonial(String id) async {
    try {
      await _client.from(SupabaseService.tableTestimonials).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
