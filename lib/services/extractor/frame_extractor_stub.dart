import 'dart:typed_data';

abstract class FrameExtractorPlatform {
  Future<double> getVideoDuration({required String videoPath, Uint8List? videoBytes});
  Future<List<Uint8List>> extractFrames({
    required String videoPath,
    Uint8List? videoBytes,
    required List<double> timestamps,
  });
}

FrameExtractorPlatform getPlatformExtractor() => throw UnsupportedError('Cannot create extractor');
