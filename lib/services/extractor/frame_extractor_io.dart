import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail_platform_interface.dart';
import 'frame_extractor_stub.dart';

class FrameExtractorIO implements FrameExtractorPlatform {
  String? _cachedFfmpegPath;
  bool _ffmpegChecked = false;

  Future<String?> _findFfmpeg() async {
    if (_ffmpegChecked) return _cachedFfmpegPath;
    _ffmpegChecked = true;

    // Check standard command in PATH
    try {
      final res = await Process.run('ffmpeg', ['-version']);
      if (res.exitCode == 0) {
        _cachedFfmpegPath = 'ffmpeg';
        return _cachedFfmpegPath;
      }
    } catch (_) {}

    // Check common known locations on Linux / macOS / Windows
    final commonPaths = [
      '/usr/bin/ffmpeg',
      '/usr/local/bin/ffmpeg',
      '/var/lib/flatpak/exports/bin/ffmpeg',
      'C:\\ffmpeg\\bin\\ffmpeg.exe',
      'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe',
    ];

    for (final path in commonPaths) {
      if (File(path).existsSync()) {
        try {
          final res = await Process.run(path, ['-version']);
          if (res.exitCode == 0) {
            _cachedFfmpegPath = path;
            return _cachedFfmpegPath;
          }
        } catch (_) {}
      }
    }

    _cachedFfmpegPath = null;
    return null;
  }

  @override
  Future<double> getVideoDuration({required String videoPath, Uint8List? videoBytes}) async {
    final ffmpeg = await _findFfmpeg();
    if (ffmpeg != null) {
      try {
        final res = await Process.run(ffmpeg, ['-i', videoPath]);
        final output = '${res.stderr}\n${res.stdout}';
        final reg = RegExp(r'Duration:\s*(\d+):(\d+):(\d+(?:\.\d+)?)');
        final match = reg.firstMatch(output);
        if (match != null) {
          final h = double.tryParse(match.group(1) ?? '0') ?? 0;
          final m = double.tryParse(match.group(2) ?? '0') ?? 0;
          final s = double.tryParse(match.group(3) ?? '0') ?? 0;
          final duration = h * 3600 + m * 60 + s;
          if (duration > 0) return duration;
        }
      } catch (e) {
        debugPrint('ffmpeg duration probe error: $e');
      }
    }

    // Fallback: default 60s
    return 60.0;
  }

  @override
  Future<List<Uint8List>> extractFrames({
    required String videoPath,
    Uint8List? videoBytes,
    required List<double> timestamps,
  }) async {
    final ffmpeg = await _findFfmpeg();
    final frames = <Uint8List>[];

    if (ffmpeg != null) {
      final tempDir = await Directory.systemTemp.createTemp('laqtat_extract_');
      try {
        for (int i = 0; i < timestamps.length; i++) {
          final t = timestamps[i];
          final outPath = '${tempDir.path}/frame_$i.jpg';
          final res = await Process.run(ffmpeg, [
            '-y',
            '-ss',
            t.toStringAsFixed(3),
            '-i',
            videoPath,
            '-frames:v',
            '1',
            '-q:v',
            '2',
            outPath,
          ]);

          final outFile = File(outPath);
          if (await outFile.exists()) {
            final bytes = await outFile.readAsBytes();
            if (bytes.isNotEmpty) {
              frames.add(bytes);
              continue;
            }
          }
          debugPrint('ffmpeg failed on frame $i at timestamp $t: ${res.stderr}');
        }
      } finally {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }

      if (frames.length == timestamps.length) {
        return frames;
      }
    }

    // If ffmpeg was missing or failed partially, try mobile native thumbnailer
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      try {
        final plugin = FcNativeVideoThumbnail();
        for (int i = frames.length; i < timestamps.length; i++) {
          final t = timestamps[i];
          final bytes = await plugin.saveThumbnailToBytes(
            srcFile: videoPath,
            width: 1280,
            height: 720,
            format: 'jpeg',
            at: FcVideoThumbnailTime(t.toInt(), FcVideoThumbnailTimeUnit.seconds),
            quality: 90,
          );
          if (bytes != null && bytes.isNotEmpty) {
            frames.add(bytes);
          }
        }
        if (frames.length == timestamps.length) {
          return frames;
        }
      } catch (e) {
        debugPrint('FcNativeVideoThumbnail fallback error: $e');
      }
    }

    if (frames.isEmpty && ffmpeg == null) {
      throw Exception('FFMPEG_NOT_FOUND');
    }

    if (frames.length < timestamps.length) {
      // If some frames failed, duplicate last frame to guarantee 8 frames
      while (frames.length < timestamps.length && frames.isNotEmpty) {
        frames.add(frames.last);
      }
    }

    return frames;
  }
}

FrameExtractorPlatform getPlatformExtractor() => FrameExtractorIO();
