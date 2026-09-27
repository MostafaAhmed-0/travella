import 'package:equatable/equatable.dart';

/// Model representing a travel destination matching Supabase public.destinations table
class DestinationModel extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final String country;
  final String imageUrl;
  final bool featured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional UI convenience fields
  final String region;
  final double startingPrice;
  final String duration;
  final double rating;
  final int reviewsCount;
  final List<String> tags;

  const DestinationModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.description,
    this.descriptionAr,
    required this.country,
    required this.imageUrl,
    this.featured = false,
    this.createdAt,
    this.updatedAt,
    this.region = 'International',
    this.startingPrice = 0.0,
    this.duration = '5 Days / 4 Nights',
    this.rating = 4.9,
    this.reviewsCount = 120,
    this.tags = const [],
  });

  /// Backward-compatibility getter for widgets using `.title`
  String get title => name;

  /// Backward-compatibility getter for widgets using `.isFeatured`
  bool get isFeatured => featured;

  /// Backward-compatibility getter for widgets using `.isPopular`
  bool get isPopular => featured;

  /// Localized name helper
  String localizedName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  /// Localized description helper
  String localizedDescription(bool isArabic) {
    if (isArabic && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      country: json['country'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      featured: (json['featured'] as bool?) ?? (json['is_featured'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      region: json['region'] as String? ?? 'International',
      startingPrice: (json['starting_price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as String? ?? '5 Days / 4 Nights',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 120,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'country': country,
      'image_url': imageUrl,
      'featured': featured,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  DestinationModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? country,
    String? imageUrl,
    bool? featured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? region,
    double? startingPrice,
    String? duration,
    double? rating,
    int? reviewsCount,
    List<String>? tags,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      country: country ?? this.country,
      imageUrl: imageUrl ?? this.imageUrl,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      region: region ?? this.region,
      startingPrice: startingPrice ?? this.startingPrice,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        country,
        imageUrl,
        featured,
        createdAt,
        updatedAt,
      ];
}
