import 'package:equatable/equatable.dart';

/// Model representing a traveler review matching Supabase public.testimonials table
class TestimonialModel extends Equatable {
  final String id;
  final String name;
  final String country;
  final String trip;
  final String review;
  final double rating;
  final String imageUrl;
  final bool active;

  // Additional UI fields
  final String clientRole;
  final String travelDate;
  final bool isVerified;

  const TestimonialModel({
    required this.id,
    required this.name,
    this.country = 'Traveler',
    this.trip = '',
    required this.review,
    this.rating = 5.0,
    required this.imageUrl,
    this.active = true,
    this.clientRole = 'Traveler',
    this.travelDate = 'Recently',
    this.isVerified = true,
  });

  /// Backward-compatibility getters
  String get clientName => name;
  String get avatarUrl => imageUrl;
  String get tripName => trip;
  String get reviewText => review;
  String get destination => country;

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['client_name'] as String? ?? '',
      country: json['country'] as String? ?? json['destination'] as String? ?? 'Traveler',
      trip: json['trip'] as String? ?? json['trip_name'] as String? ?? '',
      review: json['review'] as String? ?? json['review_text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      imageUrl: json['image_url'] as String? ?? json['avatar_url'] as String? ?? '',
      active: (json['active'] as bool?) ?? (json['is_verified'] as bool?) ?? true,
      clientRole: json['client_role'] as String? ?? 'Traveler',
      travelDate: json['travel_date'] as String? ?? 'Recently',
      isVerified: (json['is_verified'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'trip': trip,
      'review': review,
      'rating': rating,
      'image_url': imageUrl,
      'active': active,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        country,
        trip,
        review,
        rating,
        imageUrl,
        active,
      ];
}
