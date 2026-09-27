import '../datasources/testimonial_remote_data_source.dart';
import '../models/testimonial_model.dart';

/// Repository for traveler testimonials
class TestimonialRepository {
  final TestimonialRemoteDataSource _remoteDataSource;

  TestimonialRepository({TestimonialRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TestimonialRemoteDataSourceImpl();

  static const List<TestimonialModel> _mockTestimonials = [
    TestimonialModel(
      id: 't1',
      name: 'Ahmed & Sarah Mansour',
      clientRole: 'Honeymoon Couple',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      trip: 'Maldives Overwater Luxury Escape',
      country: 'Egypt',
      rating: 5.0,
      review: 'Travella orchestrated our dream honeymoon to perfection. From the private seaplane transfers to the bespoke candlelit dinner on a sandbank, every second was pure enchantment.',
      travelDate: 'September 2026',
    ),
    TestimonialModel(
      id: 't2',
      name: 'Dr. Khaled El-Sayed',
      clientRole: 'History Enthusiast & Academic',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      trip: 'Royal Nile Cruise: Aswan to Luxor',
      country: 'Saudi Arabia',
      rating: 5.0,
      review: 'The private Egyptologist provided by Travella made history come alive in ways I had never imagined. The 5-star Nile cruise ship was immaculate and the service was world-class.',
      travelDate: 'August 2026',
    ),
    TestimonialModel(
      id: 't3',
      name: 'Fatima Al-Zahraa',
      clientRole: 'Family Traveler',
      imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      trip: 'VIP Diamond Umrah Package',
      country: 'UAE',
      rating: 5.0,
      review: 'Flawless arrangements for our family Umrah. The hotel was steps away from the Haram, making it effortless for my elderly parents. May Allah reward you for such heartfelt dedication.',
      travelDate: 'July 2026',
    ),
  ];

  Future<List<TestimonialModel>> getFeaturedTestimonials() async {
    try {
      final list = await _remoteDataSource.getTestimonials();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockTestimonials;
  }

  Future<TestimonialModel> createTestimonial(TestimonialModel testimonial) =>
      _remoteDataSource.createTestimonial(testimonial);

  Future<TestimonialModel> updateTestimonial(TestimonialModel testimonial) =>
      _remoteDataSource.updateTestimonial(testimonial);

  Future<void> deleteTestimonial(String id) =>
      _remoteDataSource.deleteTestimonial(id);
}
