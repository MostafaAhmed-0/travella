import 'dart:typed_data';

class PickedFileData {
  final String name;
  final Uint8List bytes;
  final int size;
  final String? mimeType;

  const PickedFileData({
    required this.name,
    required this.bytes,
    required this.size,
    this.mimeType,
  });
}

class UniversalFilePicker {
  static Future<PickedFileData?> pickFile({
    List<String>? allowedExtensions,
    String? accept,
  }) async {
    // Non-web platform fallback mock file for testing/compilation
    return null;
  }
}
