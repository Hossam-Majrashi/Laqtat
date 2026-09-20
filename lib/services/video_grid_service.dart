import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../models/project.dart';
import 'extractor/frame_extractor.dart';
import 'grid_compositor.dart';
import 'exporter/export_service.dart';

class VideoGridService {
  final FrameExtractorPlatform _extractor = createExtractor();
  final ExportPlatform _exporter = createExporter();

  static const List<String> supportedExtensions = [
    'mp4',
    'mov',
    'mkv',
    'webm',
    'avi',
    'flv',
    'f4v',
    'wmv',
    'm4v',
    '3gp',
    '3g2',
    'mpg',
    'mpeg',
    'ts',
    'm2ts',
    'mts',
    'ogv',
    'vob',
    'rm',
    'ram',
  ];

  Future<PlatformFile?> pickVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
    );

    if (result.isNotEmpty) {
      final file = result.first;
      final ext = file.extension?.toLowerCase() ?? '';
      if (!supportedExtensions.contains(ext)) {
        throw Exception('UNSUPPORTED_FORMAT');
      }
      return file;
    }
    return null;
  }

  List<double> generateTimestamps(double duration, {List<double>? previousTimestamps}) {
    if (duration <= 0) duration = 10.0;

    if (previousTimestamps == null || previousTimestamps.isEmpty) {
      // Default: evenly spaced (duration / 9 * [1..8])
      final step = duration / 9.0;
      return List.generate(8, (i) => (i + 1) * step);
    }

    // Regenerate: sample 8 different timestamps avoiding repeating previous
    final random = Random();
    final newTimestamps = <double>[];
    final segmentSize = duration / 8.0;

    for (int i = 0; i < 8; i++) {
      final segStart = i * segmentSize;
      final prev = previousTimestamps[i];

      // Pick a point in segment that is distinctly different from previous
      double candidate;
      int attempts = 0;
      do {
        final jitter = 0.15 + random.nextDouble() * 0.70; // 15% to 85% of segment
        candidate = segStart + jitter * segmentSize;
        attempts++;
      } while ((candidate - prev).abs() < (segmentSize * 0.15) && attempts < 10);

      newTimestamps.add(double.parse(candidate.toStringAsFixed(2)));
    }

    return newTimestamps;
  }

  Future<Project> processVideo({
    required PlatformFile file,
    String quality = 'standard',
    String exportFormat = 'png',
    List<double>? customTimestamps,
  }) async {
    final videoPath = file.path ?? '';
    final videoBytes = kIsWeb ? await file.readAsBytes() : null;

    // 1. Get video duration
    final duration = await _extractor.getVideoDuration(
      videoPath: videoPath,
      videoBytes: videoBytes,
    );

    // 2. Sample 8 timestamps
    final timestamps = customTimestamps ?? generateTimestamps(duration);

    // 3. Extract 8 frames
    final frames = await _extractor.extractFrames(
      videoPath: videoPath,
      videoBytes: videoBytes,
      timestamps: timestamps,
    );

    if (frames.length < 8) {
      throw Exception('FAILED_FRAME_EXTRACTION');
    }

    // 4. Compose 4x2 grid
    final gridBytes = await GridCompositor.composeGrid(
      frames: frames,
      quality: quality,
      format: exportFormat,
    );

    final projectId = 'proj_${DateTime.now().millisecondsSinceEpoch}';
    return Project(
      id: projectId,
      title: file.name,
      videoName: file.name,
      videoPath: videoPath,
      dateCreated: DateTime.now(),
      durationSeconds: duration,
      gridImagePath: '',
      timestamps: timestamps,
      quality: quality,
      exportFormat: exportFormat,
      gridImageBytes: gridBytes,
      videoBytes: videoBytes,
    );
  }

  Future<Project> regenerateProject({
    required Project project,
    String? quality,
    String? exportFormat,
  }) async {
    final effectiveQuality = quality ?? project.quality;
    final effectiveFormat = exportFormat ?? project.exportFormat;

    final newTimestamps = generateTimestamps(
      project.durationSeconds,
      previousTimestamps: project.timestamps,
    );

    final frames = await _extractor.extractFrames(
      videoPath: project.videoPath,
      videoBytes: project.videoBytes,
      timestamps: newTimestamps,
    );

    final gridBytes = await GridCompositor.composeGrid(
      frames: frames,
      quality: effectiveQuality,
      format: effectiveFormat,
    );

    return Project(
      id: project.id,
      title: project.title,
      videoName: project.videoName,
      videoPath: project.videoPath,
      dateCreated: project.dateCreated,
      durationSeconds: project.durationSeconds,
      gridImagePath: project.gridImagePath,
      timestamps: newTimestamps,
      quality: effectiveQuality,
      exportFormat: effectiveFormat,
      gridImageBytes: gridBytes,
      videoBytes: project.videoBytes,
    );
  }

  Future<bool> exportGrid({
    required Project project,
    String? format,
    String? saveLocation,
  }) async {
    final targetFormat = format ?? project.exportFormat;
    Uint8List? exportBytes = project.gridImageBytes;

    if (exportBytes == null) {
      return false;
    }

    // Re-encode if format requested differs from project.exportFormat
    if (targetFormat.toLowerCase() != project.exportFormat.toLowerCase()) {
      // Re-encode to the requested format
      final decoded = imgDecode(exportBytes);
      if (decoded != null) {
        exportBytes = targetFormat.toLowerCase() == 'jpg'
            ? Uint8List.fromList(imgEncodeJpg(decoded))
            : Uint8List.fromList(imgEncodePng(decoded));
      }
    }

    final sanitizedName = project.videoName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final filename = '${sanitizedName}_laqtat_grid.$targetFormat';

    return await _exporter.exportImage(
      bytes: exportBytes,
      filename: filename,
      format: targetFormat,
      defaultDirectory: saveLocation,
    );
  }
}

// Helpers for re-encoding
Uint8List imgEncodePng(dynamic image) => Uint8List.fromList(img.encodePng(image));
Uint8List imgEncodeJpg(dynamic image) => Uint8List.fromList(img.encodeJpg(image, quality: 92));
dynamic imgDecode(Uint8List bytes) => img.decodeImage(bytes);
