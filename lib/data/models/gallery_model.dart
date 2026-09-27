import 'package:equatable/equatable.dart';

/// Model representing a gallery item matching Supabase public.gallery table
class GalleryModel extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final bool featured;
  final DateTime? createdAt;

  // Additional UI fields
  final String destination;
  final String country;
  final double aspectRatio;

  const GalleryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.category = 'Travel',
    this.featured = false,
    this.createdAt,
    this.destination = '',
    this.country = '',
    this.aspectRatio = 1.0,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'Travel',
      featured: (json['featured'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      destination: json['destination'] as String? ?? '',
      country: json['country'] as String? ?? '',
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'featured': featured,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  GalleryModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? category,
    bool? featured,
    DateTime? createdAt,
    String? destination,
    String? country,
    double? aspectRatio,
  }) {
    return GalleryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, category, featured, createdAt];
}

/// Backward compatibility alias
typedef GalleryItemModel = GalleryModel;
