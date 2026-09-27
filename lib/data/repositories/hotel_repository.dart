import '../models/hotel_model.dart';

/// Repository for luxury hotels and resorts
class HotelRepository {
  const HotelRepository();

  static const List<HotelModel> _mockHotels = [
    HotelModel(
      id: 'hotel-rixos-premium-sharm',
      name: 'Rixos Premium Seagate',
      city: 'Sharm El Sheikh',
      country: 'Egypt',
      address: 'Nabq Bay, Sharm El Sheikh',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.95,
      reviewsCount: 420,
      pricePerNight: 240,
      roomType: 'Deluxe Sea View Suite',
      amenities: ['Ultra All-Inclusive', 'Private Beach', '8 Pools', 'Luxury Spa', 'Free High-Speed Wi-Fi', 'Butler Service'],
      isFeatured: true,
      badge: 'Luxury Resort',
    ),
    HotelModel(
      id: 'hotel-atlantis-the-royal',
      name: 'Atlantis The Royal',
      city: 'Dubai',
      country: 'United Arab Emirates',
      address: 'Palm Jumeirah, Dubai',
      imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.98,
      reviewsCount: 560,
      pricePerNight: 680,
      roomType: 'Sky View Terrace Room',
      amenities: ['Cloud 22 Sky Pool', 'Celebrity Restaurants', 'Aquaventure Waterpark Access', 'Private Beach Club'],
      isFeatured: true,
      badge: 'Iconic Landmark',
    ),
    HotelModel(
      id: 'hotel-four-seasons-bosphorus',
      name: 'Four Seasons Hotel Bosphorus',
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Ciragan Cd. No:28, Besiktas',
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 4.94,
      reviewsCount: 310,
      pricePerNight: 490,
      roomType: 'Bosphorus Palace View',
      amenities: ['Heated Outdoor Pool on Bosphorus', 'Traditional Turkish Hammam', 'Historic 19th-Century Palace', 'Michelin-guide Dining'],
      isFeatured: true,
      badge: 'Palatial Elegance',
    ),
    HotelModel(
      id: 'hotel-waldorf-astoria-maldives',
      name: 'Waldorf Astoria Ithaafushi',
      city: 'South Male Atoll',
      country: 'Maldives',
      address: 'Ithaafushi Island',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1000&q=80',
      stars: 5,
      rating: 5.0,
      reviewsCount: 280,
      pricePerNight: 1250,
      roomType: 'Overwater Reef Villa with Pool',
      amenities: ['Private Infinity Pool', '11 World-Class Restaurants', 'Hydrotherapy Spa', 'Private Yacht Transfer'],
      isFeatured: true,
      badge: 'Ultimate Luxury',
    ),
  ];

  Future<List<HotelModel>> getFeaturedHotels() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockHotels;
  }
}
