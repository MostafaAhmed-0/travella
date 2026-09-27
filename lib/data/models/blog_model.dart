import 'package:equatable/equatable.dart';

export 'gallery_model.dart';
export 'partner_model.dart';

/// Model representing a blog post matching Supabase public.blogs table
class BlogModel extends Equatable {
  final String id;
  final String title;
  final String? titleAr;
  final String content;
  final String? contentAr;
  final String imageUrl;
  final bool published;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional UI fields
  final String slug;
  final String category;
  final String excerpt;
  final String authorName;
  final String authorAvatar;
  final String publishedAt;
  final String readTime;
  final List<String> tags;

  const BlogModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.content,
    this.contentAr,
    required this.imageUrl,
    this.published = true,
    this.createdAt,
    this.updatedAt,
    this.slug = '',
    this.category = 'Travel Guide',
    this.excerpt = '',
    this.authorName = 'Travella Editorial',
    this.authorAvatar = '',
    this.publishedAt = 'Recently',
    this.readTime = '5 min read',
    this.tags = const [],
  });

  /// Localized title helper
  String localizedTitle(bool isArabic) {
    if (isArabic && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  /// Localized content helper
  String localizedContent(bool isArabic) {
    if (isArabic && contentAr != null && contentAr!.isNotEmpty) {
      return contentAr!;
    }
    return content;
  }

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    final body = json['content'] as String? ?? '';
    final genExcerpt = body.length > 120 ? '${body.substring(0, 117)}...' : body;

    return BlogModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleAr: json['title_ar'] as String?,
      content: body,
      contentAr: json['content_ar'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      published: (json['published'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      slug: json['slug'] as String? ?? (json['id'] as String? ?? ''),
      category: json['category'] as String? ?? 'Travel Guide',
      excerpt: json['excerpt'] as String? ?? genExcerpt,
      authorName: json['author_name'] as String? ?? 'Travella Editorial',
      authorAvatar: json['author_avatar'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? 'Recently',
      readTime: json['read_time'] as String? ?? '5 min read',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'content': content,
      'content_ar': contentAr,
      'image_url': imageUrl,
      'published': published,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  BlogModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? content,
    String? contentAr,
    String? imageUrl,
    bool? published,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? slug,
    String? category,
    String? excerpt,
    String? authorName,
    String? authorAvatar,
    String? publishedAt,
    String? readTime,
    List<String>? tags,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      content: content ?? this.content,
      contentAr: contentAr ?? this.contentAr,
      imageUrl: imageUrl ?? this.imageUrl,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      excerpt: excerpt ?? this.excerpt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      publishedAt: publishedAt ?? this.publishedAt,
      readTime: readTime ?? this.readTime,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        content,
        contentAr,
        imageUrl,
        published,
        createdAt,
        updatedAt,
      ];
}
