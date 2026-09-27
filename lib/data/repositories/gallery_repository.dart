import '../datasources/gallery_remote_data_source.dart';
import '../models/gallery_model.dart';

/// Repository for gallery images with Supabase connection & fallback
class GalleryRepository {
  final GalleryRemoteDataSource _remoteDataSource;

  GalleryRepository({GalleryRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GalleryRemoteDataSourceImpl();

  static const List<GalleryModel> _mockGallery = [
    GalleryModel(
      id: 'g1',
      title: 'Santorini Sunset',
      destination: 'Santorini',
      country: 'Greece',
      category: 'Beach',
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 0.8,
      featured: true,
    ),
    GalleryModel(
      id: 'g2',
      title: 'Swiss Alps Panorama',
      destination: 'Zermatt',
      country: 'Switzerland',
      category: 'Adventure',
      imageUrl: 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 1.3,
      featured: true,
    ),
    GalleryModel(
      id: 'g3',
      title: 'Phuket Longtail Boats',
      destination: 'Phuket',
      country: 'Thailand',
      category: 'Beach',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 0.9,
      featured: true,
    ),
    GalleryModel(
      id: 'g4',
      title: 'Kyoto Bamboo Forest',
      destination: 'Kyoto',
      country: 'Japan',
      category: 'Culture',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 1.1,
      featured: true,
    ),
    GalleryModel(
      id: 'g5',
      title: 'Amalfi Coast Positano',
      destination: 'Amalfi',
      country: 'Italy',
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 0.75,
      featured: true,
    ),
    GalleryModel(
      id: 'g6',
      title: 'Dubai Desert Sunset',
      destination: 'Dubai',
      country: 'UAE',
      category: 'Desert',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80',
      aspectRatio: 1.2,
      featured: true,
    ),
  ];

  Future<List<GalleryModel>> getGalleryItems({String? category}) async {
    try {
      final items = await _remoteDataSource.getGalleryItems(category: category);
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }

    if (category == null || category == 'All') {
      return _mockGallery;
    }
    return _mockGallery.where((item) => item.category == category).toList();
  }

  Future<GalleryModel> createGalleryItem(GalleryModel item) =>
      _remoteDataSource.createGalleryItem(item);

  Future<GalleryModel> updateGalleryItem(GalleryModel item) =>
      _remoteDataSource.updateGalleryItem(item);

  Future<void> deleteGalleryItem(String id) =>
      _remoteDataSource.deleteGalleryItem(id);
}
