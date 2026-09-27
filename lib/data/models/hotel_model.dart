import 'package:equatable/equatable.dart';

/// Model representing a luxury hotel matching Supabase public.hotels table
class HotelModel extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String location;
  final double rating;
  final double price;
  final String currency;
  final String imageUrl;
  final bool featured;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional UI convenience fields
  final int stars;
  final int reviewsCount;
  final List<String> amenities;
  final List<String> galleryImages;
  final String roomType;
  final String? badge;

  const HotelModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.description = '',
    required this.location,
    this.rating = 4.9,
    required this.price,
    this.currency = 'USD',
    required this.imageUrl,
    this.featured = false,
    this.active = true,
    this.createdAt,
    this.updatedAt,
    this.stars = 5,
    this.reviewsCount = 120,
    this.amenities = const [],
    this.galleryImages = const [],
    this.roomType = 'Deluxe Suite',
    this.badge,
  });

  /// Backward-compatibility getter for widgets using `pricePerNight`
  double get pricePerNight => price;

  /// Backward-compatibility getter for widgets using `isFeatured`
  bool get isFeatured => featured;

  /// Derived city and country from location
  String get city {
    final parts = location.split(',');
    return parts.isNotEmpty ? parts.first.trim() : location;
  }

  String get country {
    final parts = location.split(',');
    return parts.length > 1 ? parts.last.trim() : '';
  }

  String get address => location;

  /// Localized name helper
  String localizedName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      price: (json['price'] as num?)?.toDouble() ?? (json['price_per_night'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      imageUrl: json['image_url'] as String? ?? '',
      featured: (json['featured'] as bool?) ?? (json['is_featured'] as bool?) ?? false,
      active: (json['active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      stars: (json['stars'] as num?)?.toInt() ?? 5,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 120,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      galleryImages: (json['gallery_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      roomType: json['room_type'] as String? ?? 'Deluxe Suite',
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'location': location,
      'rating': rating,
      'price': price,
      'currency': currency,
      'image_url': imageUrl,
      'featured': featured,
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? location,
    double? rating,
    double? price,
    String? currency,
    String? imageUrl,
    bool? featured,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stars,
    int? reviewsCount,
    List<String>? amenities,
    List<String>? galleryImages,
    String? roomType,
    String? badge,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      featured: featured ?? this.featured,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stars: stars ?? this.stars,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      amenities: amenities ?? this.amenities,
      galleryImages: galleryImages ?? this.galleryImages,
      roomType: roomType ?? this.roomType,
      badge: badge ?? this.badge,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        location,
        rating,
        price,
        currency,
        imageUrl,
        featured,
        active,
      ];
}
