import '../datasources/testimonial_remote_data_source.dart';
import '../models/testimonial_model.dart';

/// Repository for traveler testimonials connected to Supabase
class TestimonialRepository {
  final TestimonialRemoteDataSource _remoteDataSource;

  TestimonialRepository({TestimonialRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TestimonialRemoteDataSourceImpl();

  Future<List<TestimonialModel>> getFeaturedTestimonials({bool activeOnly = true}) async {
    return _remoteDataSource.getTestimonials(activeOnly: activeOnly);
  }

  Future<TestimonialModel> createTestimonial(TestimonialModel testimonial) =>
      _remoteDataSource.createTestimonial(testimonial);

  Future<TestimonialModel> updateTestimonial(TestimonialModel testimonial) =>
      _remoteDataSource.updateTestimonial(testimonial);

  Future<void> deleteTestimonial(String id) =>
      _remoteDataSource.deleteTestimonial(id);
}
