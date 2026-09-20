import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class GridCompositor {
  static Future<Uint8List> composeGrid({
    required List<Uint8List> frames,
    String quality = 'standard',
    String format = 'png',
  }) async {
    // Run in compute or background isolate to keep UI butter smooth
    return await compute(_composeGridTask, {
      'frames': frames,
      'quality': quality,
      'format': format,
    });
  }

  static Uint8List _composeGridTask(Map<String, dynamic> args) {
    final frames = args['frames'] as List<Uint8List>;
    final quality = args['quality'] as String? ?? 'standard';
    final format = args['format'] as String? ?? 'png';

    final isHigh = quality.toLowerCase() == 'high';
    final tileWidth = isHigh ? 960 : 480;
    final tileHeight = isHigh ? 540 : 270;
    final gap = isHigh ? 16 : 8;

    const cols = 4;
    const rows = 2;

    final totalWidth = cols * tileWidth + (cols + 1) * gap;
    final totalHeight = rows * tileHeight + (rows + 1) * gap;

    // Background color: sleek dark border
    final gridImage = img.Image(width: totalWidth, height: totalHeight);
    img.fill(gridImage, color: img.ColorRgb8(24, 26, 30));

    const targetAspect = 16.0 / 9.0;

    for (int i = 0; i < 8; i++) {
      if (i >= frames.length) break;

      final frameBytes = frames[i];
      final decoded = img.decodeImage(frameBytes);
      if (decoded == null) continue;

      img.Image cropped;
      final currentAspect = decoded.width / decoded.height;

      if ((currentAspect - targetAspect).abs() < 0.05) {
        cropped = decoded;
      } else if (currentAspect > targetAspect) {
        // Video is wider than 16:9
        final cropWidth = (decoded.height * targetAspect).toInt();
        final startX = (decoded.width - cropWidth) ~/ 2;
        cropped = img.copyCrop(
          decoded,
          x: startX,
          y: 0,
          width: cropWidth,
          height: decoded.height,
        );
      } else {
        // Video is taller (e.g. portrait 9:16 or 4:3)
        final cropHeight = (decoded.width / targetAspect).toInt();
        final startY = (decoded.height - cropHeight) ~/ 2;
        cropped = img.copyCrop(
          decoded,
          x: 0,
          y: startY,
          width: decoded.width,
          height: cropHeight,
        );
      }

      final resized = img.copyResize(
        cropped,
        width: tileWidth,
        height: tileHeight,
        interpolation: img.Interpolation.linear,
      );

      final col = i % cols;
      final row = i ~/ cols;
      final x = gap + col * (tileWidth + gap);
      final y = gap + row * (tileHeight + gap);

      img.compositeImage(gridImage, resized, dstX: x, dstY: y);
    }

    if (format.toLowerCase() == 'jpg' || format.toLowerCase() == 'jpeg') {
      return Uint8List.fromList(img.encodeJpg(gridImage, quality: isHigh ? 95 : 85));
    } else {
      return Uint8List.fromList(img.encodePng(gridImage));
    }
  }
}
