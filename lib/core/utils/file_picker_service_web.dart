// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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
    final completer = Completer<PickedFileData?>();
    final input = html.FileUploadInputElement();

    if (accept != null) {
      input.accept = accept;
    } else if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      input.accept = allowedExtensions.map((e) => e.startsWith('.') ? e : '.$e').join(',');
    }

    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      final file = files[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(PickedFileData(
            name: file.name,
            bytes: result,
            size: file.size,
            mimeType: file.type,
          ));
        } else if (result is ByteBuffer) {
          completer.complete(PickedFileData(
            name: file.name,
            bytes: Uint8List.view(result),
            size: file.size,
            mimeType: file.type,
          ));
        } else if (result is List<int>) {
          completer.complete(PickedFileData(
            name: file.name,
            bytes: Uint8List.fromList(result),
            size: file.size,
            mimeType: file.type,
          ));
        } else {
          completer.complete(null);
        }
      });

      reader.onError.listen((e) {
        if (!completer.isCompleted) completer.complete(null);
      });

      reader.readAsArrayBuffer(file);
    });

    return completer.future;
  }
}
