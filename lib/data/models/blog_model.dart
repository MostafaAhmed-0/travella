/// Model for travel inspiration and editorial blog posts
class BlogModel {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String excerpt;
  final String content;
  final String imageUrl;
  final String authorName;
  final String authorAvatar;
  final String publishedAt;
  final String readTime;
  final List<String> tags;

  const BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.excerpt,
    this.content = '',
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatar,
    required this.publishedAt,
    required this.readTime,
    this.tags = const [],
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? 'Travel Guide',
      excerpt: json['excerpt'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Travella Editorial',
      authorAvatar: json['author_avatar'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? 'Recently',
      readTime: json['read_time'] as String? ?? '5 min read',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'category': category,
      'excerpt': excerpt,
      'content': content,
      'image_url': imageUrl,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'published_at': publishedAt,
      'read_time': readTime,
      'tags': tags,
    };
  }
}

/// Model for masonry travel gallery
class GalleryItemModel {
  final String id;
  final String title;
  final String destination;
  final String country;
  final String category; // 'Beach', 'Culture', 'Adventure', 'Luxury', 'Desert'
  final String imageUrl;
  final double aspectRatio;

  const GalleryItemModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.country,
    required this.category,
    required this.imageUrl,
    this.aspectRatio = 1.0,
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    return GalleryItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      country: json['country'] as String? ?? '',
      category: json['category'] as String? ?? 'Travel',
      imageUrl: json['image_url'] as String? ?? '',
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'country': country,
      'category': category,
      'image_url': imageUrl,
      'aspect_ratio': aspectRatio,
    };
  }
}

/// Model for airline & hotel partners
class PartnerModel {
  final String id;
  final String name;
  final String category; // 'Airlines', 'Hotels', 'Tourism Boards'
  final String logoUrl;
  final String website;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    this.website = '',
  });
}
