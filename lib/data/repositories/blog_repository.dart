import '../datasources/blog_remote_data_source.dart';
import '../models/blog_model.dart';

/// Repository for blog articles
class BlogRepository {
  final BlogRemoteDataSource _remoteDataSource;

  BlogRepository({BlogRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? BlogRemoteDataSourceImpl();

  static const List<BlogModel> _mockBlogs = [
    BlogModel(
      id: 'b1',
      title: 'Top 10 Hidden Gems in Egypt You Must Visit in 2026',
      titleAr: 'أفضل 10 أماكن ساحرة ومخفية في مصر يجب زيارتها في عام 2026',
      slug: 'top-10-hidden-gems-egypt',
      category: 'Destinations',
      excerpt: 'From the mystical salt pools of Siwa to Marsa Alam’s pristine coral reefs, explore Egypt beyond the Pyramids.',
      content: 'From the crystalline salt lakes of Siwa Oasis to the serene turquoise bays of Marsa Alam and the bohemian charm of Dahab, discover Egypt beyond the iconic Pyramids.',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
      authorName: 'Travella Editorial',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
      publishedAt: 'Oct 15, 2026',
      readTime: '6 min read',
      tags: ['Egypt', 'Hidden Gems', 'Adventure'],
      published: true,
    ),
    BlogModel(
      id: 'b2',
      title: 'The Ultimate Luxury Travel Packing Guide for Europe',
      titleAr: 'الدليل الشامل لأناقة السفر الفاخر عبر العواصم الأوروبية',
      slug: 'luxury-packing-guide-europe',
      category: 'Travel Tips',
      excerpt: 'Curate the perfect capsule wardrobe and travel tech for seamless transit across European capitals.',
      content: 'Expert tips on capsule wardrobes, premium travel accessories, electronic adapters, and navigating European climates with effortless style and comfort.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
      authorName: 'Sophia Laurent',
      authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80',
      publishedAt: 'Oct 08, 2026',
      readTime: '5 min read',
      tags: ['Europe', 'Luxury', 'Packing'],
      published: true,
    ),
    BlogModel(
      id: 'b3',
      title: 'Essential Spiritual & Practical Guide for First-Time Umrah Pilgrims',
      titleAr: 'الدليل الروحي والعملي المتكامل للمعتمرين لأول مرة',
      slug: 'essential-umrah-guide',
      category: 'Hajj & Umrah',
      excerpt: 'Everything you need to know about Ihram, Tawaf, hotel proximity, and spiritual preparation for Makkah and Madinah.',
      content: 'A comprehensive step-by-step walkthrough covering Ihram requirements, Tawaf and Sa’i etiquette, recommended prayers, and packing essentials for Makkah and Madinah.',
      imageUrl: 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=800&q=80',
      authorName: 'Sheikh Dr. Tariq',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
      publishedAt: 'Sep 28, 2026',
      readTime: '8 min read',
      tags: ['Umrah', 'Spirituality', 'Makkah'],
      published: true,
    ),
  ];

  Future<List<BlogModel>> getFeaturedArticles() async {
    try {
      final list = await _remoteDataSource.getBlogs();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockBlogs;
  }

  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final list = await _remoteDataSource.getBlogs();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockBlogs;
  }

  Future<BlogModel?> getBlogById(String id) async {
    try {
      final item = await _remoteDataSource.getBlogById(id);
      if (item != null) return item;
    } catch (_) {
      // Fallback
    }
    try {
      return _mockBlogs.firstWhere((b) => b.id == id || b.slug == id);
    } catch (_) {
      return null;
    }
  }

  Future<BlogModel> createBlog(BlogModel blog) => _remoteDataSource.createBlog(blog);
  Future<BlogModel> updateBlog(BlogModel blog) => _remoteDataSource.updateBlog(blog);
  Future<void> deleteBlog(String id) => _remoteDataSource.deleteBlog(id);
}
