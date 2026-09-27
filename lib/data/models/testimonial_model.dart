/// Model representing traveler testimonial / review
class TestimonialModel {
  final String id;
  final String clientName;
  final String clientRole;
  final String avatarUrl;
  final String tripName;
  final String destination;
  final double rating;
  final String reviewText;
  final String travelDate;
  final bool isVerified;

  const TestimonialModel({
    required this.id,
    required this.clientName,
    required this.clientRole,
    required this.avatarUrl,
    required this.tripName,
    required this.destination,
    required this.rating,
    required this.reviewText,
    required this.travelDate,
    this.isVerified = true,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: json['id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      clientRole: json['client_role'] as String? ?? 'Traveler',
      avatarUrl: json['avatar_url'] as String? ?? '',
      tripName: json['trip_name'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: json['review_text'] as String? ?? '',
      travelDate: json['travel_date'] as String? ?? 'Recently',
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'client_role': clientRole,
      'avatar_url': avatarUrl,
      'trip_name': tripName,
      'destination': destination,
      'rating': rating,
      'review_text': reviewText,
      'travel_date': travelDate,
      'is_verified': isVerified,
    };
  }
}
