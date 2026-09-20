import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'export_service_stub.dart';

class ExportServiceIO implements ExportPlatform {
  @override
  Future<bool> exportImage({
    required Uint8List bytes,
    required String filename,
    required String format,
    String? defaultDirectory,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Direct save to MediaStore / Photo Gallery (no share sheet)
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          final granted = await Gal.requestAccess();
          if (!granted) return false;
        }

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$filename';
        final tempFile = File(filePath);
        await tempFile.writeAsBytes(bytes);

        await Gal.putImage(tempFile.path);

        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}

        return true;
      } else {
        // Desktop: check if custom directory is configured or prompt save dialog
        if (defaultDirectory != null && defaultDirectory.isNotEmpty) {
          final dir = Directory(defaultDirectory);
          if (await dir.exists()) {
            final targetPath = '${dir.path}/$filename';
            await File(targetPath).writeAsBytes(bytes);
            return true;
          }
        }

        // Open save dialog and save bytes
        final saveUri = await FilePicker.saveFile(
          dialogTitle: 'Save Grid Image',
          fileName: filename,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: [format.toLowerCase()],
        );

        return saveUri != null;
      }
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }
}

ExportPlatform getExportPlatform() => ExportServiceIO();
