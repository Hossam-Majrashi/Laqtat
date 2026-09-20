import 'package:flutter/foundation.dart';

abstract class ExportPlatform {
  Future<bool> exportImage({
    required Uint8List bytes,
    required String filename,
    required String format,
    String? defaultDirectory,
  });
}

ExportPlatform getExportPlatform() => throw UnsupportedError('Export not supported');
