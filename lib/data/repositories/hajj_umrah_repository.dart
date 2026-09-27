import '../models/hajj_umrah_model.dart';

export 'testimonial_repository.dart';
export 'blog_repository.dart';
export 'gallery_repository.dart';
export 'partner_repository.dart';

/// Repository for Hajj & Umrah spiritual packages
class HajjUmrahRepository {
  const HajjUmrahRepository();

  static const List<HajjUmrahPackageModel> packages = [
    HajjUmrahPackageModel(
      id: 'umrah-vip-5star',
      title: 'VIP 5-Star Umrah Package',
      subtitle: 'Luxury accommodations directly overlooking the Haram',
      category: 'Umrah',
      makkahHotel: 'Fairmont Makkah Clock Royal Tower',
      madinahHotel: 'The Oberoi Madina',
      makkahDistance: '0 meters (Direct Haram Access)',
      madinahDistance: '50 meters to Prophet\'s Mosque',
      durationDays: '10 Days / 9 Nights',
      price: 1450,
      imageUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&w=1000&q=80',
      inclusions: [
        'Direct Flight (EgyptAir / Saudia)',
        'Private VIP GMC / Luxury Coach Transfers',
        'Open Buffet Gourmet Breakfast & Dinner',
        'VIP Visa Processing & Electronic Permits',
        'Guided Holy Ziyarat in Makkah & Madinah',
        '24/7 Dedicated Religious Supervisor',
      ],
      isPopular: true,
      badge: '5-Star VIP',
    ),
    HajjUmrahPackageModel(
      id: 'umrah-ramadan-full',
      title: 'Ramadan Spiritual Blessing (Last 10 Days)',
      subtitle: 'Experience Laylatul Qadr in the Holy Sanctuary',
      category: 'Ramadan Umrah',
      makkahHotel: 'Swissôtel Al Maqam Makkah',
      madinahHotel: 'Dar Al Taqwa Madinah',
      makkahDistance: 'Direct Haram Courtyard',
      madinahDistance: 'Front row to Al-Masjid an-Nabawi',
      durationDays: '15 Days / 14 Nights',
      price: 2450,
      imageUrl: 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
      inclusions: [
        'Roundtrip Flights',
        'Suhoor & Iftar Buffet Inclusions',
        'Haramain High-Speed Train VIP Tickets',
        'Complete Electronic Nusuk Permit Handling',
        'Luggage Chaperone Service',
      ],
      isPopular: true,
      badge: 'Ramadan Special',
    ),
    HajjUmrahPackageModel(
      id: 'hajj-vip-exclusive',
      title: 'Exclusive Deluxe Hajj Experience',
      subtitle: 'Complete premium comfort and specialized religious guidance',
      category: 'Hajj',
      makkahHotel: 'Raffles Makkah Palace',
      madinahHotel: 'Madinah Hilton',
      makkahDistance: 'Facing King Abdulaziz Gate',
      madinahDistance: 'Direct Prophet\'s Gate',
      durationDays: '21 Days',
      price: 5800,
      imageUrl: 'https://images.unsplash.com/photo-1542810634-71277d95dcbb?auto=format&fit=crop&w=1000&q=80',
      inclusions: [
        'Air-conditioned VIP Mena & Arafat Platinum Tents',
        'Private Luxury Transportation',
        'Full Board 5-Star Catering throughout',
        'Doctor & Dedicated Medical Escort',
        'Comprehensive Hajj Guide & Scholars',
      ],
      isPopular: false,
      badge: 'Platinum Hajj',
    ),
  ];

  Future<List<HajjUmrahPackageModel>> getPackages() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return packages;
  }
}
