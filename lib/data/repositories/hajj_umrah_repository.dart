import '../models/hajj_umrah_model.dart';
import '../models/testimonial_model.dart';
import '../models/blog_model.dart';

/// Repository for Hajj & Umrah Packages
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

/// Repository for Testimonials
class TestimonialRepository {
  const TestimonialRepository();

  static const List<TestimonialModel> testimonials = [
    TestimonialModel(
      id: 'test-1',
      clientName: 'Dr. Tarek Mansour',
      clientRole: 'CEO, Horizon Ventures',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      tripName: 'Paris & French Riviera',
      destination: 'France',
      rating: 5.0,
      reviewText: 'Travella crafted an immaculate French getaway for my family. From our private Seine yacht dinner to skipping queues at Versailles, every detail was executed with world-class precision.',
      travelDate: 'October 2025',
      isVerified: true,
    ),
    TestimonialModel(
      id: 'test-2',
      clientName: 'Yasmin & Karim El-Sayed',
      clientRole: 'Honeymoon Travelers',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      tripName: 'Maldives Overwater Sanctuary',
      destination: 'Maldives',
      rating: 5.0,
      reviewText: 'The best honeymoon we could ever dream of! The overwater villa, the surprise candlelit beach dinner, and the seaplane arrival arranged by Travella were pure magic. Explore a Brighter World is truly their promise kept.',
      travelDate: 'December 2025',
      isVerified: true,
    ),
    TestimonialModel(
      id: 'test-3',
      clientName: 'Engineer Ahmed Radwan',
      clientRole: 'Senior Architect',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      tripName: 'Royal Nile Cruise (Aswan to Luxor)',
      destination: 'Egypt',
      rating: 5.0,
      reviewText: 'As an Egyptian who loves our history, I was blown away by the quality of this Nile cruise. The private Egyptologist was phenomenal, the cruiser was top-tier luxury, and the hot air balloon flight at sunrise was unforgettable.',
      travelDate: 'January 2026',
      isVerified: true,
    ),
    TestimonialModel(
      id: 'test-4',
      clientName: 'Nouran Al-Sabah',
      clientRole: 'Interior Designer',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      tripName: 'Bosphorus & Cappadocia Dream',
      destination: 'Turkey',
      rating: 4.9,
      reviewText: 'Super smooth visa processing, excellent boutique hotel in Istanbul with Bosphorus view, and seamless cave hotel transfers in Cappadocia. Travella is now our permanent travel advisor!',
      travelDate: 'February 2026',
      isVerified: true,
    ),
  ];

  Future<List<TestimonialModel>> getTestimonials() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return testimonials;
  }
}

/// Repository for Travel Blogs
class BlogRepository {
  const BlogRepository();

  static const List<BlogModel> blogs = [
    BlogModel(
      id: 'blog-siwa-guide',
      title: 'The Hidden Magic of Siwa: 7 Secrets of Egypt’s Desert Oasis',
      slug: 'hidden-magic-of-siwa-secrets',
      category: 'Egypt Travel',
      excerpt: 'Discover hypersaline floating salt lakes, sustainable eco-lodges made of kershef, and the mystical warmth of Cleopatra Spring.',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
      authorName: 'Layla Mahmoud',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      publishedAt: 'Feb 15, 2026',
      readTime: '6 min read',
      tags: ['Siwa', 'Eco-Tourism', 'Desert Safari'],
    ),
    BlogModel(
      id: 'blog-istanbul-neighborhoods',
      title: 'An Insider Guide to Istanbul: Beyond the Grand Bazaar',
      slug: 'insider-guide-istanbul-neighborhoods',
      category: 'International Guide',
      excerpt: 'From the colorful wooden houses of Balat to the chic rooftop cafes of Karaköy and a sunset ferry across two continents.',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=800&q=80',
      authorName: 'Omar Farouk',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      publishedAt: 'Feb 28, 2026',
      readTime: '8 min read',
      tags: ['Istanbul', 'Culture', 'Culinary'],
    ),
    BlogModel(
      id: 'blog-maldives-luxury',
      title: 'How to Choose Your Dream Maldives Resort: Water Villa vs Beach Suite',
      slug: 'choose-dream-maldives-resort',
      category: 'Luxury Travel',
      excerpt: 'Direct reef access or sunset beachfront? Here is everything you need to know before booking your paradise escape.',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=800&q=80',
      authorName: 'Salma El-Gohary',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      publishedAt: 'Mar 10, 2026',
      readTime: '5 min read',
      tags: ['Maldives', 'Honeymoon', 'Luxury'],
    ),
  ];

  Future<List<BlogModel>> getBlogs() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return blogs;
  }
}

/// Repository for Gallery Items
class GalleryRepository {
  const GalleryRepository();

  static const List<GalleryItemModel> items = [
    GalleryItemModel(
      id: 'gal-1',
      title: 'Red Sea Crystal Waters',
      destination: 'Hurghada',
      country: 'Egypt',
      category: 'Beach',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.33,
    ),
    GalleryItemModel(
      id: 'gal-2',
      title: 'Eiffel Tower Sunset Glow',
      destination: 'Paris',
      country: 'France',
      category: 'Culture',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 0.8,
    ),
    GalleryItemModel(
      id: 'gal-3',
      title: 'Overwater Lagoon Villas',
      destination: 'Maldives',
      country: 'Maldives',
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.2,
    ),
    GalleryItemModel(
      id: 'gal-4',
      title: 'Sultanahmet Mosque Twilight',
      destination: 'Istanbul',
      country: 'Turkey',
      category: 'Culture',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.0,
    ),
    GalleryItemModel(
      id: 'gal-5',
      title: 'Siwa Salt Lake Mirage',
      destination: 'Siwa Oasis',
      country: 'Egypt',
      category: 'Desert',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.4,
    ),
    GalleryItemModel(
      id: 'gal-6',
      title: 'Karnak Temple Hypostyle Hall',
      destination: 'Luxor',
      country: 'Egypt',
      category: 'Culture',
      imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 0.9,
    ),
    GalleryItemModel(
      id: 'gal-7',
      title: 'Dubai Marina Skylight',
      destination: 'Dubai',
      country: 'UAE',
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.1,
    ),
    GalleryItemModel(
      id: 'gal-8',
      title: 'Ras Mohammed Coral Reefs',
      destination: 'Sharm El Sheikh',
      country: 'Egypt',
      category: 'Adventure',
      imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1200&q=85',
      aspectRatio: 1.3,
    ),
  ];

  Future<List<GalleryItemModel>> getGalleryItems() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return items;
  }
}

/// Repository for Airline & Hospitality Partners
class PartnerRepository {
  const PartnerRepository();

  static const List<PartnerModel> partners = [
    PartnerModel(id: 'p-1', name: 'Emirates', category: 'Airlines', logoUrl: 'Emirates'),
    PartnerModel(id: 'p-2', name: 'Qatar Airways', category: 'Airlines', logoUrl: 'Qatar Airways'),
    PartnerModel(id: 'p-3', name: 'Turkish Airlines', category: 'Airlines', logoUrl: 'Turkish Airlines'),
    PartnerModel(id: 'p-4', name: 'EgyptAir', category: 'Airlines', logoUrl: 'EgyptAir'),
    PartnerModel(id: 'p-5', name: 'Marriott International', category: 'Hotels', logoUrl: 'Marriott'),
    PartnerModel(id: 'p-6', name: 'Hilton Hotels & Resorts', category: 'Hotels', logoUrl: 'Hilton'),
    PartnerModel(id: 'p-7', name: 'Four Seasons', category: 'Hotels', logoUrl: 'Four Seasons'),
    PartnerModel(id: 'p-8', name: 'Rixos Hotels', category: 'Hotels', logoUrl: 'Rixos Hotels'),
    PartnerModel(id: 'p-9', name: 'Fairmont Hotels', category: 'Hotels', logoUrl: 'Fairmont'),
    PartnerModel(id: 'p-10', name: 'Accor Group', category: 'Hotels', logoUrl: 'Accor'),
  ];

  Future<List<PartnerModel>> getPartners() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return partners;
  }
}
