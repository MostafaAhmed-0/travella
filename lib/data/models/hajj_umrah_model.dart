/// Model representing Hajj and Umrah spiritual packages
class HajjUmrahPackageModel {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'Umrah', 'Ramadan Umrah', 'Hajj VIP'
  final String makkahHotel;
  final String madinahHotel;
  final String makkahDistance;
  final String madinahDistance;
  final String durationDays;
  final double price;
  final String imageUrl;
  final List<String> inclusions;
  final bool isPopular;
  final String? badge;

  const HajjUmrahPackageModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.makkahHotel,
    required this.madinahHotel,
    required this.makkahDistance,
    required this.madinahDistance,
    required this.durationDays,
    required this.price,
    required this.imageUrl,
    this.inclusions = const [],
    this.isPopular = false,
    this.badge,
  });

  factory HajjUmrahPackageModel.fromJson(Map<String, dynamic> json) {
    return HajjUmrahPackageModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? 'Umrah',
      makkahHotel: json['makkah_hotel'] as String? ?? '',
      madinahHotel: json['madinah_hotel'] as String? ?? '',
      makkahDistance: json['makkah_distance'] as String? ?? 'Directly on Haram',
      madinahDistance: json['madinah_distance'] as String? ?? 'Directly on Haram',
      durationDays: json['duration_days'] as String? ?? '14 Days',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      inclusions: (json['inclusions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['is_popular'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'makkah_hotel': makkahHotel,
      'madinah_hotel': madinahHotel,
      'makkah_distance': makkahDistance,
      'madinah_distance': madinahDistance,
      'duration_days': durationDays,
      'price': price,
      'image_url': imageUrl,
      'inclusions': inclusions,
      'is_popular': isPopular,
      'badge': badge,
    };
  }
}
