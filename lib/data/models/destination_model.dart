/// Model representing a travel destination
class DestinationModel {
  final String id;
  final String title;
  final String country;
  final String region; // 'Egypt', 'Europe', 'Middle East', 'Asia', 'Exotic'
  final String description;
  final String imageUrl;
  final double startingPrice;
  final String duration;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isPopular;
  final List<String> tags;

  const DestinationModel({
    required this.id,
    required this.title,
    required this.country,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.startingPrice,
    required this.duration,
    required this.rating,
    required this.reviewsCount,
    this.isFeatured = false,
    this.isPopular = false,
    this.tags = const [],
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      country: json['country'] as String? ?? '',
      region: json['region'] as String? ?? 'International',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      startingPrice: (json['starting_price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'country': country,
      'region': region,
      'description': description,
      'image_url': imageUrl,
      'starting_price': startingPrice,
      'duration': duration,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'is_popular': isPopular,
      'tags': tags,
    };
  }
}
