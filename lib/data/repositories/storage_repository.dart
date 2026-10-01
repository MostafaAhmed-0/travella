import 'dart:typed_data';
import '../../core/constants/app_constants.dart';
import '../datasources/storage_remote_data_source.dart';

/// Repository for handling image & asset uploads to Supabase Storage
abstract class StorageRepository {
  Future<String> uploadTourImage(Uint8List bytes, String filename);
  Future<String> uploadDestinationImage(Uint8List bytes, String filename);
  Future<String> uploadHotelImage(Uint8List bytes, String filename);
  Future<String> uploadGalleryImage(Uint8List bytes, String filename);
  Future<String> uploadBlogImage(Uint8List bytes, String filename);
  Future<String> uploadPartnerLogo(Uint8List bytes, String filename);
  Future<String> uploadVisaDocument(Uint8List bytes, String filename, {String? userId});
  Future<void> deleteFile(String bucket, String path);
}

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource _remoteDataSource;

  StorageRepositoryImpl({StorageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? StorageRemoteDataSourceImpl();

  String _sanitizePath(String filename, {String? prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final clean = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    if (prefix != null && prefix.isNotEmpty) {
      return '$prefix/$timestamp-$clean';
    }
    return '$timestamp-$clean';
  }

  @override
  Future<String> uploadTourImage(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.toursBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadDestinationImage(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.destinationsBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadHotelImage(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.hotelsBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadGalleryImage(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.galleryBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadBlogImage(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.blogsBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadPartnerLogo(Uint8List bytes, String filename) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.partnerLogosBucket,
      path: _sanitizePath(filename),
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadVisaDocument(Uint8List bytes, String filename, {String? userId}) {
    return _remoteDataSource.uploadBytes(
      bucket: AppConstants.visaDocumentsBucket,
      path: _sanitizePath(filename, prefix: userId ?? 'guest'),
      bytes: bytes,
    );
  }

  @override
  Future<void> deleteFile(String bucket, String path) {
    return _remoteDataSource.deleteFile(bucket: bucket, path: path);
  }
}
