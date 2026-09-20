import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'export_service_stub.dart';

class ExportServiceWeb implements ExportPlatform {
  @override
  Future<bool> exportImage({
    required Uint8List bytes,
    required String filename,
    required String format,
    String? defaultDirectory,
  }) async {
    try {
      final mime = format.toLowerCase() == 'jpg' || format.toLowerCase() == 'jpeg'
          ? 'image/jpeg'
          : 'image/png';
      final jsArray = bytes.toJS;
      final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: mime));
      final url = web.URL.createObjectURL(blob);

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = filename;
      web.document.body?.appendChild(anchor);
      anchor.click();
      web.document.body?.removeChild(anchor);

      web.URL.revokeObjectURL(url);
      return true;
    } catch (e) {
      debugPrint('Web export error: $e');
      return false;
    }
  }
}

ExportPlatform getExportPlatform() => ExportServiceWeb();
