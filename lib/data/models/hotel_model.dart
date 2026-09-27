/// Model representing a luxury hotel or resort
class HotelModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String address;
  final String imageUrl;
  final List<String> galleryImages;
  final int stars; // 1 to 5
  final double rating;
  final int reviewsCount;
  final double pricePerNight;
  final List<String> amenities;
  final String roomType;
  final bool isFeatured;
  final String? badge;

  const HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.address,
    required this.imageUrl,
    this.galleryImages = const [],
    this.stars = 5,
    this.rating = 4.9,
    this.reviewsCount = 120,
    required this.pricePerNight,
    this.amenities = const [],
    this.roomType = 'Deluxe Suite',
    this.isFeatured = false,
    this.badge,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      galleryImages: (json['gallery_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stars: (json['stars'] as num?)?.toInt() ?? 5,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0.0,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      roomType: json['room_type'] as String? ?? 'Deluxe Suite',
      isFeatured: json['is_featured'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'address': address,
      'image_url': imageUrl,
      'gallery_images': galleryImages,
      'stars': stars,
      'rating': rating,
      'reviews_count': reviewsCount,
      'price_per_night': pricePerNight,
      'amenities': amenities,
      'room_type': roomType,
      'is_featured': isFeatured,
      'badge': badge,
    };
  }
}
