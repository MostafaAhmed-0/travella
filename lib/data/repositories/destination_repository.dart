import '../datasources/destination_remote_data_source.dart';
import '../models/destination_model.dart';

/// Repository for Destination data connecting to Supabase with resilient fallback
class DestinationRepository {
  final DestinationRemoteDataSource _remoteDataSource;

  DestinationRepository({DestinationRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DestinationRemoteDataSourceImpl();

  static const List<DestinationModel> _mockDestinations = [
    DestinationModel(
      id: 'd1111111-1111-1111-1111-111111111111',
      name: 'Istanbul',
      nameAr: 'إسطنبول',
      country: 'Turkey',
      region: 'Europe & Asia',
      description: 'Where East meets West across the Bosphorus strait. Iconic mosques, grand bazaars, and Ottoman palaces.',
      descriptionAr: 'حيث يلتقي الشرق بالغرب عبر مضيق البوسفور. مساجد عثمانية أيقونية، وأسواق تاريخية نابضة بالحياة.',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 580,
      duration: '5 Days / 4 Nights',
      rating: 4.9,
      reviewsCount: 342,
      featured: true,
      tags: ['Culture', 'History', 'Shopping', 'Bosphorus'],
    ),
    DestinationModel(
      id: 'd2222222-2222-2222-2222-222222222222',
      name: 'Paris',
      nameAr: 'باريس',
      country: 'France',
      region: 'Europe',
      description: 'The City of Light. Romantic Seine cruises, Louvre masterpieces, and timeless haute cuisine.',
      descriptionAr: 'مدينة النور. رحلات رومانسية في نهر السين، وروائع متحف اللوفر، وأرقى فنون الطهي الفرنسية.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 1150,
      duration: '6 Days / 5 Nights',
      rating: 4.95,
      reviewsCount: 520,
      featured: true,
      tags: ['Romantic', 'Art', 'Luxury', 'Eiffel'],
    ),
    DestinationModel(
      id: 'd3333333-3333-3333-3333-333333333333',
      name: 'Dubai',
      nameAr: 'دبي',
      country: 'United Arab Emirates',
      region: 'Middle East',
      description: 'Ultra-modern marvels, desert safaris, world-class shopping, and private yacht cruises in the Arabian Gulf.',
      descriptionAr: 'عجائب معمارية فائقة الحداثة، ورحلات سفاري صحراوية، وتسوق عالمي، ويخوت فاخرة في الخليج العربي.',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 850,
      duration: '5 Days / 4 Nights',
      rating: 4.9,
      reviewsCount: 410,
      featured: true,
      tags: ['Luxury', 'Desert Safari', 'Modern', 'Shopping'],
    ),
    DestinationModel(
      id: 'd4444444-4444-4444-4444-444444444444',
      name: 'Maldives',
      nameAr: 'المالديف',
      country: 'Maldives',
      region: 'Exotic',
      description: 'Overwater luxury villas, pristine turquoise lagoons, and private coral reef diving experiences.',
      descriptionAr: 'فلل فاخرة فوق الماء، وبحيرات فيروزية نقية، وتجارب غوص فريدة بين الشعاب المرجانية.',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 1650,
      duration: '7 Days / 6 Nights',
      rating: 5.0,
      reviewsCount: 610,
      featured: true,
      tags: ['Overwater Villa', 'Honeymoon', 'Diving', 'Paradise'],
    ),
    DestinationModel(
      id: 'd5555555-5555-5555-5555-555555555555',
      name: 'Sharm El Sheikh',
      nameAr: 'شرم الشيخ',
      country: 'Egypt',
      region: 'Egypt',
      description: 'The Jewel of Sinai. World-renowned diving in Ras Mohammed, luxury all-inclusive resorts, and desert stargazing.',
      descriptionAr: 'لؤلؤة سيناء. غوص عالمي في رأس محمد، ومنتجعات شاملة راقية، وسهرات صحراوية تحت النجوم.',
      imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 340,
      duration: '4 Days / 3 Nights',
      rating: 4.9,
      reviewsCount: 450,
      featured: true,
      tags: ['Red Sea', 'Diving', 'Sinai', 'All-Inclusive'],
    ),
    DestinationModel(
      id: 'd6666666-6666-6666-6666-666666666666',
      name: 'Hurghada',
      nameAr: 'الغردقة',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Crystal-clear turquoise waters of Giftun Island, desert quad safaris, and vibrant marine coral life.',
      descriptionAr: 'مياه فيروزية صافية في جزيرة جفتون، ورحلات سفاري بالدراجات الرباعية، وتنوع بحري رائع.',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 310,
      duration: '4 Days / 3 Nights',
      rating: 4.85,
      reviewsCount: 390,
      featured: true,
      tags: ['Beach', 'Water Sports', 'Island Tour'],
    ),
    DestinationModel(
      id: 'd7777777-7777-7777-7777-777777777777',
      name: 'Siwa Oasis',
      nameAr: 'واحة سيوة',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Mystical eco-lodges, crystal salt lakes, Cleopatra springs, and sunset over the Great Sand Sea dunes.',
      descriptionAr: 'نزل بيئية ساحرة، وبحيرات ملح كريستالية، وعين كليوباترا، وغروب مهيب فوق بحر الرمال الأعظم.',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 420,
      duration: '4 Days / 3 Nights',
      rating: 4.95,
      reviewsCount: 230,
      featured: true,
      tags: ['Eco-Lodge', 'Salt Lakes', 'Desert Safari', 'Oasis'],
    ),
    DestinationModel(
      id: 'd8888888-8888-8888-8888-888888888888',
      name: 'Aswan & Luxor',
      nameAr: 'أسوان والأقصر',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Pharaonic grandeur along the timeless Nile. Valley of the Kings, Karnak, and Philae Temple.',
      descriptionAr: 'عظمة الفراعنة على ضفاف النيل الخالد. وادي الملوك، ومعابد الكرنك، وفيلة.',
      imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 490,
      duration: '5 Days / 4 Nights',
      rating: 4.95,
      reviewsCount: 380,
      featured: true,
      tags: ['Nile Cruise', 'Pharaohs', 'History', 'Temples'],
    ),
  ];

  Future<List<DestinationModel>> getDestinations({String? region}) async {
    try {
      final items = await _remoteDataSource.getDestinations();
      if (items.isNotEmpty) {
        if (region == null || region == 'All') return items;
        return items.where((d) => d.region == region || d.tags.contains(region)).toList();
      }
    } catch (_) {
      // Fallback
    }

    if (region == null || region == 'All') {
      return _mockDestinations;
    }
    return _mockDestinations.where((d) => d.region == region || d.tags.contains(region)).toList();
  }

  Future<List<DestinationModel>> getFeaturedDestinations() async {
    try {
      final items = await _remoteDataSource.getDestinations(featuredOnly: true);
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }
    return _mockDestinations.where((d) => d.isFeatured).toList();
  }

  Future<DestinationModel?> getDestinationById(String id) async {
    try {
      final item = await _remoteDataSource.getDestinationById(id);
      if (item != null) return item;
    } catch (_) {
      // Fallback
    }
    try {
      return _mockDestinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DestinationModel> createDestination(DestinationModel destination) async {
    return _remoteDataSource.createDestination(destination);
  }

  Future<DestinationModel> updateDestination(DestinationModel destination) async {
    return _remoteDataSource.updateDestination(destination);
  }

  Future<void> deleteDestination(String id) async {
    return _remoteDataSource.deleteDestination(id);
  }
}
