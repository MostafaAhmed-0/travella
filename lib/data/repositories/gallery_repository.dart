import '../datasources/gallery_remote_data_source.dart';
import '../models/gallery_model.dart';

/// Repository for gallery images connected to Supabase
class GalleryRepository {
  final GalleryRemoteDataSource _remoteDataSource;

  GalleryRepository({GalleryRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GalleryRemoteDataSourceImpl();

  Future<List<GalleryModel>> getGalleryItems({String? category, bool? featuredOnly}) async {
    return _remoteDataSource.getGalleryItems(
      category: category,
      featuredOnly: featuredOnly,
    );
  }

  Future<GalleryModel> createGalleryItem(GalleryModel item) =>
      _remoteDataSource.createGalleryItem(item);

  Future<GalleryModel> updateGalleryItem(GalleryModel item) =>
      _remoteDataSource.updateGalleryItem(item);

  Future<void> deleteGalleryItem(String id) =>
      _remoteDataSource.deleteGalleryItem(id);
}
