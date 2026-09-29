import '../datasources/blog_remote_data_source.dart';
import '../models/blog_model.dart';

/// Repository for blog articles connected to Supabase
class BlogRepository {
  final BlogRemoteDataSource _remoteDataSource;

  BlogRepository({BlogRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? BlogRemoteDataSourceImpl();

  Future<List<BlogModel>> getFeaturedArticles() async {
    return _remoteDataSource.getBlogs(publishedOnly: true);
  }

  Future<List<BlogModel>> getAllBlogs({bool publishedOnly = true}) async {
    return _remoteDataSource.getBlogs(publishedOnly: publishedOnly);
  }

  Future<BlogModel?> getBlogById(String id) async {
    return _remoteDataSource.getBlogById(id);
  }

  Future<BlogModel> createBlog(BlogModel blog) => _remoteDataSource.createBlog(blog);
  Future<BlogModel> updateBlog(BlogModel blog) => _remoteDataSource.updateBlog(blog);
  Future<void> deleteBlog(String id) => _remoteDataSource.deleteBlog(id);
}
