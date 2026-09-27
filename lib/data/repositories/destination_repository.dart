import '../models/destination_model.dart';

/// Repository for Destination data
class DestinationRepository {
  const DestinationRepository();

  /// Mock destinations matching the project requirements
  static const List<DestinationModel> _mockDestinations = [
    DestinationModel(
      id: 'dest-istanbul',
      title: 'Istanbul',
      country: 'Turkey',
      region: 'Europe & Asia',
      description: 'Where East meets West across the Bosphorus strait. Iconic mosques, grand bazaars, and Ottoman palaces.',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 580,
      duration: '5 Days / 4 Nights',
      rating: 4.9,
      reviewsCount: 342,
      isFeatured: true,
      isPopular: true,
      tags: ['Culture', 'History', 'Shopping', 'Bosphorus'],
    ),
    DestinationModel(
      id: 'dest-paris',
      title: 'Paris',
      country: 'France',
      region: 'Europe',
      description: 'The City of Light. Romantic Seine cruises, Louvre masterpieces, and timeless haute cuisine.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 1150,
      duration: '6 Days / 5 Nights',
      rating: 4.95,
      reviewsCount: 520,
      isFeatured: true,
      isPopular: true,
      tags: ['Romantic', 'Art', 'Luxury', 'Eiffel'],
    ),
    DestinationModel(
      id: 'dest-dubai',
      title: 'Dubai',
      country: 'United Arab Emirates',
      region: 'Middle East',
      description: 'Ultra-modern marvels, desert safaris, world-class shopping, and private yacht cruises in the Arabian Gulf.',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 850,
      duration: '5 Days / 4 Nights',
      rating: 4.9,
      reviewsCount: 410,
      isFeatured: true,
      isPopular: true,
      tags: ['Luxury', 'Desert Safari', 'Modern', 'Shopping'],
    ),
    DestinationModel(
      id: 'dest-amsterdam',
      title: 'Amsterdam',
      country: 'Netherlands',
      region: 'Europe',
      description: 'Charming canal rings, historic merchant mansions, vibrant tulip fields, and world-class museums.',
      imageUrl: 'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 980,
      duration: '5 Days / 4 Nights',
      rating: 4.85,
      reviewsCount: 280,
      isFeatured: false,
      isPopular: true,
      tags: ['Canals', 'Architecture', 'Culture'],
    ),
    DestinationModel(
      id: 'dest-maldives',
      title: 'Maldives',
      country: 'Maldives',
      region: 'Exotic',
      description: 'Overwater luxury villas, pristine turquoise lagoons, and private coral reef diving experiences.',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 1650,
      duration: '7 Days / 6 Nights',
      rating: 5.0,
      reviewsCount: 610,
      isFeatured: true,
      isPopular: true,
      tags: ['Overwater Villa', 'Honeymoon', 'Diving', 'Paradise'],
    ),
    DestinationModel(
      id: 'dest-sharm',
      title: 'Sharm El Sheikh',
      country: 'Egypt',
      region: 'Egypt',
      description: 'The Jewel of Sinai. World-renowned diving in Ras Mohammed, luxury all-inclusive resorts, and desert stargazing.',
      imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 340,
      duration: '4 Days / 3 Nights',
      rating: 4.9,
      reviewsCount: 450,
      isFeatured: true,
      isPopular: true,
      tags: ['Red Sea', 'Diving', 'Sinai', 'All-Inclusive'],
    ),
    DestinationModel(
      id: 'dest-hurghada',
      title: 'Hurghada',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Crystal-clear turquoise waters of Giftun Island, desert quad safaris, and vibrant marine coral life.',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 310,
      duration: '4 Days / 3 Nights',
      rating: 4.85,
      reviewsCount: 390,
      isFeatured: true,
      isPopular: true,
      tags: ['Beach', 'Water Sports', 'Island Tour'],
    ),
    DestinationModel(
      id: 'dest-siwa',
      title: 'Siwa Oasis',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Mystical eco-lodges, crystal salt lakes, Cleopatra springs, and sunset over the Great Sand Sea dunes.',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 420,
      duration: '4 Days / 3 Nights',
      rating: 4.95,
      reviewsCount: 230,
      isFeatured: true,
      isPopular: false,
      tags: ['Eco-Lodge', 'Salt Lakes', 'Desert Safari', 'Oasis'],
    ),
    DestinationModel(
      id: 'dest-aswan',
      title: 'Aswan & Luxor',
      country: 'Egypt',
      region: 'Egypt',
      description: 'Pharaonic grandeur along the timeless Nile. Valley of the Kings, Karnak, and Philae Temple.',
      imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1200&q=85',
      startingPrice: 490,
      duration: '5 Days / 4 Nights',
      rating: 4.95,
      reviewsCount: 380,
      isFeatured: true,
      isPopular: true,
      tags: ['Nile Cruise', 'Pharaohs', 'History', 'Temples'],
    ),
  ];

  Future<List<DestinationModel>> getDestinations({String? region}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (region == null || region == 'All') {
      return _mockDestinations;
    }
    return _mockDestinations.where((d) => d.region == region || d.tags.contains(region)).toList();
  }

  Future<List<DestinationModel>> getFeaturedDestinations() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockDestinations.where((d) => d.isFeatured).toList();
  }

  Future<DestinationModel?> getDestinationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _mockDestinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
