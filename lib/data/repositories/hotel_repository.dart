import '../datasources/hotel_remote_data_source.dart';
import '../models/hotel_model.dart';

/// Repository for luxury hotels and resorts with Supabase remote data source
class HotelRepository {
  final HotelRemoteDataSource _remoteDataSource;

  HotelRepository({HotelRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? HotelRemoteDataSourceImpl();

  static const List<HotelModel> _mockHotels = [
    HotelModel(
      id: 'h1111111-1111-1111-1111-111111111111',
      name: 'Rixos Premium Seagate',
      nameAr: 'ريكسوس بريميوم سيجيت',
      location: 'Nabq Bay, Sharm El Sheikh, Egypt',
      description: 'Ultra all-inclusive 5-star beachfront resort in Nabq Bay with 8 swimming pools and a luxury spa.',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.95,
      reviewsCount: 420,
      price: 240,
      roomType: 'Deluxe Sea View Suite',
      amenities: ['Ultra All-Inclusive', 'Private Beach', '8 Pools', 'Luxury Spa', 'Free High-Speed Wi-Fi', 'Butler Service'],
      featured: true,
      badge: 'Luxury Resort',
    ),
    HotelModel(
      id: 'h2222222-2222-2222-2222-222222222222',
      name: 'Atlantis The Royal',
      nameAr: 'أتلانتس ذا رويال',
      location: 'Palm Jumeirah, Dubai, UAE',
      description: 'Iconic ultra-luxury resort on Palm Jumeirah with Cloud 22 sky pool and celebrity restaurants.',
      imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.98,
      reviewsCount: 560,
      price: 680,
      roomType: 'Sky View Terrace Room',
      amenities: ['Cloud 22 Sky Pool', 'Celebrity Restaurants', 'Aquaventure Waterpark Access', 'Private Beach Club'],
      featured: true,
      badge: 'Iconic Landmark',
    ),
    HotelModel(
      id: 'h3333333-3333-3333-3333-333333333333',
      name: 'Four Seasons Hotel Bosphorus',
      nameAr: 'فور سيزونز البوسفور',
      location: 'Besiktas, Istanbul, Turkey',
      description: '19th-century Ottoman palace on the Bosphorus with heated outdoor pool and Michelin-guide dining.',
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.94,
      reviewsCount: 310,
      price: 490,
      roomType: 'Bosphorus Palace View',
      amenities: ['Heated Outdoor Pool on Bosphorus', 'Traditional Turkish Hammam', 'Historic 19th-Century Palace', 'Michelin-guide Dining'],
      featured: true,
      badge: 'Palatial Elegance',
    ),
    HotelModel(
      id: 'h4444444-4444-4444-4444-444444444444',
      name: 'Waldorf Astoria Ithaafushi',
      nameAr: 'والدورف أستوريا إيثافوشي',
      location: 'South Male Atoll, Maldives',
      description: 'Pinnacle of luxury overwater villas with private infinity pools and dedicated butler service.',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 5.0,
      reviewsCount: 280,
      price: 1250,
      roomType: 'Overwater Reef Villa with Pool',
      amenities: ['Private Infinity Pool', '11 World-Class Restaurants', 'Hydrotherapy Spa', 'Private Yacht Transfer'],
      featured: true,
      badge: 'Ultimate Luxury',
    ),
  ];

  Future<List<HotelModel>> getFeaturedHotels() async {
    try {
      final hotels = await _remoteDataSource.getHotels(featuredOnly: true);
      if (hotels.isNotEmpty) return hotels;
    } catch (_) {
      // Fallback
    }
    return _mockHotels;
  }

  Future<List<HotelModel>> getAllHotels() async {
    try {
      final hotels = await _remoteDataSource.getHotels();
      if (hotels.isNotEmpty) return hotels;
    } catch (_) {
      // Fallback
    }
    return _mockHotels;
  }

  Future<HotelModel?> getHotelById(String id) async {
    try {
      final hotel = await _remoteDataSource.getHotelById(id);
      if (hotel != null) return hotel;
    } catch (_) {
      // Fallback
    }
    try {
      return _mockHotels.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<HotelModel> createHotel(HotelModel hotel) => _remoteDataSource.createHotel(hotel);
  Future<HotelModel> updateHotel(HotelModel hotel) => _remoteDataSource.updateHotel(hotel);
  Future<void> deleteHotel(String id) => _remoteDataSource.deleteHotel(id);
}
