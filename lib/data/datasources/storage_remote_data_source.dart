import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

abstract class StorageRemoteDataSource {
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  });

  Future<void> deleteFile({
    required String bucket,
    required String path,
  });

  String getPublicUrl({
    required String bucket,
    required String path,
  });
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final SupabaseClient _client;

  StorageRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType ?? 'image/jpeg',
              upsert: true,
            ),
          );
      return getPublicUrl(bucket: bucket, path: path);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
