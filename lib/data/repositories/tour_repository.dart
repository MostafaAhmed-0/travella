import '../datasources/tour_remote_data_source.dart';
import '../models/tour_model.dart';

/// Repository for tours connecting to Supabase with resilient fallback
class TourRepository {
  final TourRemoteDataSource _remoteDataSource;

  TourRepository({TourRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TourRemoteDataSourceImpl();

  static const List<TourModel> _mockDomesticTours = [
    TourModel(
      id: 't1111111-1111-1111-1111-111111111111',
      title: 'Hurghada Red Sea & Giftun Island Adventure',
      titleAr: 'مغامرة الغردقة والبحر الأحمر وجزيرة جفتون',
      destination: 'Hurghada',
      country: 'Egypt',
      type: TourType.domestic,
      description: 'Experience 5-star beachfront luxury, private boat cruise to Giftun Island, snorkeling in coral reefs, and desert dinner.',
      descriptionAr: 'استمتع بإقامة فاخرة 5 نجوم على الشاطئ، ورحلة يخت خاصة إلى جزيرة جفتون، وغوص وسط الشعاب المرجانية.',
      imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1000&q=80',
      price: 320,
      originalPrice: 390,
      duration: '4 Days / 3 Nights',
      rating: 4.9,
      reviewsCount: 142,
      highlights: ['5-Star Beachfront Resort', 'Giftun Island Yacht Cruise', 'Desert Bedouin Dinner', 'Snorkeling Equipment'],
      included: ['Flight / VIP Coach', 'All-Inclusive Meals', 'Island Excursion', 'Tour Leader'],
      isSpecialOffer: true,
      badge: 'Best Seller',
      featured: true,
    ),
    TourModel(
      id: 't2222222-2222-2222-2222-222222222222',
      title: 'Sharm El Sheikh Ras Mohammed & Sinai Safari',
      titleAr: 'شرم الشيخ رأس محمد وسفاري سيناء',
      destination: 'Sharm El Sheikh',
      country: 'Egypt',
      type: TourType.domestic,
      description: 'Exclusive resort stay at Naama Bay, world-famous diving at Ras Mohammed National Park, and Mount Sinai sunrise hike.',
      descriptionAr: 'إقامة حصرية في خليج نعمة، وغوص في محمية رأس محمد العالمية، وصعود جبل موسى عند شروق الشمس.',
      imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1000&q=80',
      price: 360,
      originalPrice: 420,
      duration: '5 Days / 4 Nights',
      rating: 4.95,
      reviewsCount: 198,
      highlights: ['Ras Mohammed Marine Park', 'Quad Safari in Sinai Desert', 'Naama Bay VIP Experience'],
      included: ['Resort Accommodation', 'All Meals & Drinks', 'Safari Excursions', 'Airport Transfers'],
      isSpecialOffer: false,
      badge: 'Luxury Pick',
      featured: true,
    ),
    TourModel(
      id: 't3333333-3333-3333-3333-333333333333',
      title: 'Siwa Eco-Lodge & Salt Lakes Escape',
      titleAr: 'رحلة واحة سيوة وبحيرات الملح الساحرة',
      destination: 'Siwa Oasis',
      country: 'Egypt',
      type: TourType.domestic,
      description: 'Unplug in the magical Siwa Oasis. Swim in hypersaline turquoise lakes, stay at an eco-lodge, explore Shali Fortress.',
      descriptionAr: 'انعزل في واحة سيوة الساحرة. اسبح في بحيرات الملح الفيروزية، وأقم في نزل بيئي فاخر، واستكشف قلعة شالي.',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1000&q=80',
      price: 430,
      duration: '4 Days / 3 Nights',
      rating: 4.98,
      reviewsCount: 88,
      highlights: ['Hypersaline Salt Lakes Swim', 'Authentic Eco-Lodge Stay', 'Great Sand Sea Dune Bashing', 'Cleopatra Spring'],
      included: ['4x4 Desert Transport', 'Eco-Lodge Stay', 'All Siwan Organic Meals', 'Desert Guide'],
      isSpecialOffer: false,
      badge: 'Hidden Gem',
      featured: false,
    ),
    TourModel(
      id: 't4444444-4444-4444-4444-444444444444',
      title: 'Royal Nile Cruise: Aswan to Luxor Heritage',
      titleAr: 'رحلة نايل كروز الملكية: تراث أسوان والأقصر',
      destination: 'Aswan & Luxor',
      country: 'Egypt',
      type: TourType.domestic,
      description: 'Sail the timeless Nile aboard a 5-star luxury cruise ship. Private guided tours of Valley of the Kings, Karnak, and Philae Temple.',
      descriptionAr: 'أبحر في نهر النيل الخالد على متن باخرة سياحية 5 نجوم فاخرة، مع جولات خاصة لوادي الملوك والكرنك.',
      imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1000&q=80',
      price: 520,
      originalPrice: 620,
      duration: '5 Days / 4 Nights',
      rating: 5.0,
      reviewsCount: 264,
      highlights: ['5-Star Luxury Nile Cruiser', 'Valley of the Kings Access', 'Hot Air Balloon over Luxor', 'Private Egyptologist'],
      included: ['Cabin with Panoramic Window', 'Full Board Gourmet Meals', 'All Temple Entrance Tickets', 'Egyptologist Guide'],
      isSpecialOffer: true,
      badge: 'Top Rated',
      featured: true,
    ),
  ];

  static const List<TourModel> _mockInternationalTours = [
    TourModel(
      id: 't5555555-5555-5555-5555-555555555555',
      title: 'Grand Istanbul & Ottoman Palaces',
      titleAr: 'إسطنبول الكبرى والقصور العثمانية',
      destination: 'Istanbul',
      country: 'Turkey',
      type: TourType.international,
      description: 'Immerse in the magic of Istanbul with private Bosphorus yacht sunset cruise, Hagia Sophia entry, and Taksim culinary walk.',
      descriptionAr: 'عش سحر إسطنبول مع رحلة يخت خاصة في البوسفور عند الغروب، وزيارة آيا صوفيا، وجولة طعام في تقسيم.',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1000&q=80',
      price: 640,
      originalPrice: 750,
      duration: '6 Days / 5 Nights',
      rating: 4.94,
      reviewsCount: 310,
      highlights: ['Private Bosphorus Sunset Yacht', 'Hagia Sophia & Blue Mosque', 'Princes’ Islands Day Cruise', 'Taksim Shopping & Dining'],
      included: ['International Flights', '4-Star Central Hotel', 'Daily Breakfast', 'Guided Excursions', 'Airport VIP Transfer'],
      isSpecialOffer: true,
      badge: 'Featured',
      featured: true,
    ),
    TourModel(
      id: 't6666666-6666-6666-6666-666666666666',
      title: 'Romantic Paris & Versailles Splendor',
      titleAr: 'باريس الرومانسية وروعة فرساي',
      destination: 'Paris',
      country: 'France',
      type: TourType.international,
      description: 'Experience Paris in supreme comfort. Seine dinner cruise, Palace of Versailles day tour, Louvre guided visit, and Montmartre walks.',
      descriptionAr: 'اختبر باريس بأقصى درجات الراحة والرفاهية. عشاء على متن باخرة بالسين، وجولة في قصر فرساي ومتحف اللوفر.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1000&q=80',
      price: 1280,
      originalPrice: 1450,
      duration: '7 Days / 6 Nights',
      rating: 4.96,
      reviewsCount: 420,
      highlights: ['Eiffel Tower Summit Access', 'Gourmet Seine Dinner Cruise', 'Palace of Versailles Tour', 'Louvre Museum Fast-Track'],
      included: ['Roundtrip Flights', '4-Star Parisian Hotel', 'Daily Breakfast', 'All Entry Passes', 'Airport VIP Transfers'],
      isSpecialOffer: false,
      badge: 'Iconic',
      featured: true,
    ),
    TourModel(
      id: 't7777777-7777-7777-7777-777777777777',
      title: 'Dubai Ultimate Luxury & Desert Dunes',
      titleAr: 'دبي قمة الفخامة والكثبان الصحراوية',
      destination: 'Dubai',
      country: 'United Arab Emirates',
      type: TourType.international,
      description: 'Burj Khalifa At The Top sky lounge, VIP 4x4 desert safari with private barbecue, Marina luxury yacht cruise, and Dubai Mall shopping.',
      descriptionAr: 'برج خليفة، وسفاري صحراوي بسيارات دفع رباعي مع عشاء باربكيو فاخر، ورحلة يخت في مارينا دبي.',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1000&q=80',
      price: 890,
      duration: '5 Days / 4 Nights',
      rating: 4.9,
      reviewsCount: 290,
      highlights: ['Burj Khalifa Level 148 Lounge', 'Premium Desert Safari & BBQ', 'Private Marina Yacht Cruise', 'Museum of the Future'],
      included: ['Direct Flights', '5-Star Downtown Hotel', 'Daily Breakfast', 'Desert Safari', 'Private Transfers'],
      isSpecialOffer: true,
      badge: 'Popular',
      featured: true,
    ),
    TourModel(
      id: 't8888888-8888-8888-8888-888888888888',
      title: 'Maldives Overwater Luxury Escape',
      titleAr: 'ملاذ المالديف الفاخر فوق الماء',
      destination: 'Maldives',
      country: 'Maldives',
      type: TourType.international,
      description: 'The pinnacle of barefoot luxury. Private overwater bungalow with direct ocean access, dolphin sunset cruise, and spa treatments.',
      descriptionAr: 'فيلا خاصة فوق المياه مع وصول مباشر للمحيط، ورحلة لمشاهدة الدلافين، ووجبات فاخرة متكاملة.',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1000&q=80',
      price: 1850,
      originalPrice: 2100,
      duration: '6 Days / 5 Nights',
      rating: 5.0,
      reviewsCount: 380,
      highlights: ['Private Overwater Villa', 'Dolphin Sunset Yacht Tour', 'Complimentary Snorkeling Kit', 'Floating Champagne Breakfast'],
      included: ['Seaplane Transfer', '5-Star Resort Overwater Villa', 'All-Inclusive Gourmet Dining', 'Spa Voucher'],
      isSpecialOffer: false,
      badge: 'VIP Honeymoon',
      featured: true,
    ),
  ];

  static const List<TourModel> _mockHajjUmrahTours = [
    TourModel(
      id: 't9999999-9999-9999-9999-999999999999',
      title: 'VIP Diamond Umrah Package',
      titleAr: 'باقة العمرة الماسية VIP',
      destination: 'Makkah & Madinah',
      country: 'Saudi Arabia',
      type: TourType.umrah,
      description: '5-star front-row Haram hotels in Makkah (Clock Tower) & Madinah (Oberoi), private luxury transfers, guided ziyarat.',
      descriptionAr: 'فنادق 5 نجوم مطلة مباشرة على الحرم في مكة والمدينة، تنقلات خاصة بسيارات فاخرة، ومرشد ديني متخصص.',
      imageUrl: 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
      price: 1650,
      duration: '10 Days / 9 Nights',
      rating: 4.98,
      reviewsCount: 154,
      highlights: ['Clock Tower Front-Row Suite', 'Madinah Oberoi Hotel', 'VIP Private GMC Transfers', 'Comprehensive Ziyarat Tour'],
      included: ['5-Star Hotels', 'Daily Buffet Breakfast', 'Private Transfers', 'Visa Processing'],
      badge: 'VIP Diamond',
      featured: true,
    ),
    TourModel(
      id: 'tbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      title: 'Royal Platinum Hajj Package',
      titleAr: 'باقة الحج الملكية البلاتينية',
      destination: 'Makkah, Madinah & Holy Sites',
      country: 'Saudi Arabia',
      type: TourType.hajj,
      description: 'Complete 5-star VIP Hajj pilgrimage with air-conditioned Mina & Arafat VIP camps, private transfers, and scholar guides.',
      descriptionAr: 'رحلة حج متكاملة VIP بأرقى معايير الراحة، خيام مكيفة في منى وعرفة، تنقلات خاصة وإشراف ديني ونخبة من العلماء.',
      imageUrl: 'https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?auto=format&fit=crop&w=1000&q=80',
      price: 5900,
      duration: '18 Days / 17 Nights',
      rating: 5.0,
      reviewsCount: 210,
      highlights: ['VIP Mina Air-Conditioned Tents', 'Private Haramain High-Speed Train', 'Dedicated Scholar & Guide', '5-Star Full Board'],
      included: ['Flights', '5-Star Hotels', 'Mina/Arafat VIP Camps', 'All Meals & Transfers'],
      badge: 'Royal Platinum',
      featured: true,
    ),
  ];

  Future<List<TourModel>> getDomesticTours() async {
    try {
      final tours = await _remoteDataSource.getTours(type: TourType.domestic);
      if (tours.isNotEmpty) return tours;
    } catch (_) {
      // Fallback
    }
    return _mockDomesticTours;
  }

  Future<List<TourModel>> getInternationalTours() async {
    try {
      final tours = await _remoteDataSource.getTours(type: TourType.international);
      if (tours.isNotEmpty) return tours;
    } catch (_) {
      // Fallback
    }
    return _mockInternationalTours;
  }

  Future<List<TourModel>> getHajjUmrahTours() async {
    try {
      final hajj = await _remoteDataSource.getTours(type: TourType.hajj);
      final umrah = await _remoteDataSource.getTours(type: TourType.umrah);
      final combined = [...hajj, ...umrah];
      if (combined.isNotEmpty) return combined;
    } catch (_) {
      // Fallback
    }
    return _mockHajjUmrahTours;
  }

  Future<List<TourModel>> getAllTours() async {
    try {
      final tours = await _remoteDataSource.getTours();
      if (tours.isNotEmpty) return tours;
    } catch (_) {
      // Fallback
    }
    return [..._mockDomesticTours, ..._mockInternationalTours, ..._mockHajjUmrahTours];
  }

  Future<TourModel?> getTourById(String id) async {
    try {
      final tour = await _remoteDataSource.getTourById(id);
      if (tour != null) return tour;
    } catch (_) {
      // Fallback
    }
    try {
      return [..._mockDomesticTours, ..._mockInternationalTours, ..._mockHajjUmrahTours]
          .firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<TourModel> createTour(TourModel tour) => _remoteDataSource.createTour(tour);
  Future<TourModel> updateTour(TourModel tour) => _remoteDataSource.updateTour(tour);
  Future<void> deleteTour(String id) => _remoteDataSource.deleteTour(id);
}
