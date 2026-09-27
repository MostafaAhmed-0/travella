enum TourType { domestic, international }

/// Model representing a package tour
class TourModel {
  final String id;
  final String title;
  final String destination;
  final String country;
  final TourType type;
  final String description;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String durationDays;
  final double rating;
  final int reviewsCount;
  final List<String> highlights;
  final List<String> included;
  final bool isSpecialOffer;
  final String? badge;

  const TourModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.country,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.durationDays,
    this.rating = 4.9,
    this.reviewsCount = 48,
    this.highlights = const [],
    this.included = const [],
    this.isSpecialOffer = false,
    this.badge,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      country: json['country'] as String? ?? '',
      type: (json['type'] == 'domestic') ? TourType.domestic : TourType.international,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      durationDays: json['duration_days'] as String? ?? '5 Days / 4 Nights',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      included: (json['included'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isSpecialOffer: json['is_special_offer'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'country': country,
      'type': type == TourType.domestic ? 'domestic' : 'international',
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'original_price': originalPrice,
      'duration_days': durationDays,
      'rating': rating,
      'reviews_count': reviewsCount,
      'highlights': highlights,
      'included': included,
      'is_special_offer': isSpecialOffer,
      'badge': badge,
    };
  }
}
