import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blog_model.dart';
import '../services/supabase_service.dart';

abstract class BlogRemoteDataSource {
  Future<List<BlogModel>> getBlogs({bool publishedOnly = true});
  Future<BlogModel?> getBlogById(String id);
  Future<BlogModel> createBlog(BlogModel blog);
  Future<BlogModel> updateBlog(BlogModel blog);
  Future<void> deleteBlog(String id);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient _client;

  BlogRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<BlogModel>> getBlogs({bool publishedOnly = true}) async {
    try {
      var query = _client.from(SupabaseService.tableBlogs).select();
      if (publishedOnly) {
        query = query.eq('published', true);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => BlogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<BlogModel?> getBlogById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableBlogs)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return BlogModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<BlogModel> createBlog(BlogModel blog) async {
    try {
      final map = blog.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableBlogs)
          .insert(map)
          .select()
          .single();
      return BlogModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<BlogModel> updateBlog(BlogModel blog) async {
    try {
      final map = blog.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableBlogs)
          .update(map)
          .eq('id', blog.id)
          .select()
          .single();
      return BlogModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteBlog(String id) async {
    try {
      await _client.from(SupabaseService.tableBlogs).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}
