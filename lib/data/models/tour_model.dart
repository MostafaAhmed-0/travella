import 'package:equatable/equatable.dart';

/// Enum representing tour types supported by Travella
enum TourType {
  domestic,
  international,
  hajj,
  umrah;

  static TourType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'domestic':
        return TourType.domestic;
      case 'international':
        return TourType.international;
      case 'hajj':
        return TourType.hajj;
      case 'umrah':
        return TourType.umrah;
      default:
        return TourType.domestic;
    }
  }

  String toDbString() {
    switch (this) {
      case TourType.domestic:
        return 'domestic';
      case TourType.international:
        return 'international';
      case TourType.hajj:
        return 'hajj';
      case TourType.umrah:
        return 'umrah';
    }
  }
}

/// Model representing auxiliary tour gallery images
class TourImageModel extends Equatable {
  final String id;
  final String tourId;
  final String imageUrl;
  final int sortOrder;

  const TourImageModel({
    required this.id,
    required this.tourId,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  factory TourImageModel.fromJson(Map<String, dynamic> json) {
    return TourImageModel(
      id: json['id'] as String? ?? '',
      tourId: json['tour_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tour_id': tourId,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, tourId, imageUrl, sortOrder];
}

/// Model representing an itinerary day/step
class TourItineraryItem extends Equatable {
  final int day;
  final String title;
  final String description;
  final List<String> activities;

  const TourItineraryItem({
    required this.day,
    required this.title,
    required this.description,
    this.activities = const [],
  });

  factory TourItineraryItem.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return TourItineraryItem(
        day: (json['day'] as num?)?.toInt() ?? 1,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        activities: (json['activities'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
    } else if (json is String) {
      return TourItineraryItem(
        day: 1,
        title: json,
        description: '',
      );
    }
    return const TourItineraryItem(day: 1, title: '', description: '');
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'title': title,
        'description': description,
        'activities': activities,
      };

  @override
  List<Object?> get props => [day, title, description, activities];
}

/// Model representing a tour package matching Supabase public.tours table
class TourModel extends Equatable {
  final String id;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final String? destinationId;
  final TourType type;
  final String duration;
  final double price;
  final double? originalPrice;
  final String currency;
  final String imageUrl;
  final bool featured;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TourImageModel> tourImages;

  // Additional UI fields for rich presentation
  final String destination;
  final String country;
  final double rating;
  final int reviewsCount;
  final List<String> highlights;
  final List<String> included;
  final List<String> excluded;
  final List<TourItineraryItem> itinerary;
  final bool isSpecialOffer;
  final String? badge;

  const TourModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    this.destinationId,
    required this.type,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    required this.imageUrl,
    this.featured = false,
    this.active = true,
    this.createdAt,
    this.updatedAt,
    this.tourImages = const [],
    this.destination = '',
    this.country = '',
    this.rating = 4.9,
    this.reviewsCount = 48,
    this.highlights = const [],
    this.included = const [],
    this.excluded = const [],
    this.itinerary = const [],
    this.isSpecialOffer = false,
    this.badge,
  });

  /// Backward-compatibility getter for widgets using `durationDays`
  String get durationDays => duration;

  /// Localized title helper
  String localizedTitle(bool isArabic) {
    if (isArabic && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  /// Localized description helper
  String localizedDescription(bool isArabic) {
    if (isArabic && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  factory TourModel.fromJson(Map<String, dynamic> json) {
    List<TourImageModel> images = [];
    if (json['tour_images'] != null && json['tour_images'] is List) {
      images = (json['tour_images'] as List)
          .map((e) => TourImageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String> highlightsList = [];
    if (json['highlights'] != null && json['highlights'] is List) {
      highlightsList = (json['highlights'] as List).map((e) => e.toString()).toList();
    }

    List<String> includedList = [];
    if (json['included'] != null && json['included'] is List) {
      includedList = (json['included'] as List).map((e) => e.toString()).toList();
    }

    List<String> excludedList = [];
    if (json['excluded'] != null && json['excluded'] is List) {
      excludedList = (json['excluded'] as List).map((e) => e.toString()).toList();
    }

    List<TourItineraryItem> itineraryList = [];
    if (json['itinerary'] != null && json['itinerary'] is List) {
      itineraryList = (json['itinerary'] as List)
          .map((e) => TourItineraryItem.fromJson(e))
          .toList();
    }

    return TourModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleAr: json['title_ar'] as String?,
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      destinationId: json['destination_id'] as String?,
      type: TourType.fromString(json['type'] as String?),
      duration: json['duration'] as String? ??
          json['duration_days'] as String? ??
          '5 Days / 4 Nights',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      imageUrl: json['image_url'] as String? ?? '',
      featured: (json['featured'] as bool?) ?? false,
      active: (json['active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      tourImages: images,
      destination: json['destination'] as String? ?? '',
      country: json['country'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      highlights: highlightsList,
      included: includedList,
      excluded: excludedList,
      itinerary: itineraryList,
      isSpecialOffer: (json['is_special_offer'] as bool?) ?? false,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'destination_id': destinationId,
      'type': type.toDbString(),
      'duration': duration,
      'price': price,
      'currency': currency,
      'image_url': imageUrl,
      'featured': featured,
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  TourModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? destinationId,
    TourType? type,
    String? duration,
    double? price,
    double? originalPrice,
    String? currency,
    String? imageUrl,
    bool? featured,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TourImageModel>? tourImages,
    String? destination,
    String? country,
    double? rating,
    int? reviewsCount,
    List<String>? highlights,
    List<String>? included,
    List<String>? excluded,
    List<TourItineraryItem>? itinerary,
    bool? isSpecialOffer,
    String? badge,
  }) {
    return TourModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      destinationId: destinationId ?? this.destinationId,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      featured: featured ?? this.featured,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tourImages: tourImages ?? this.tourImages,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      highlights: highlights ?? this.highlights,
      included: included ?? this.included,
      excluded: excluded ?? this.excluded,
      itinerary: itinerary ?? this.itinerary,
      isSpecialOffer: isSpecialOffer ?? this.isSpecialOffer,
      badge: badge ?? this.badge,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        description,
        descriptionAr,
        destinationId,
        type,
        duration,
        price,
        currency,
        imageUrl,
        featured,
        active,
      ];
}
