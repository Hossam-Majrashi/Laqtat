import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'frame_extractor_stub.dart';

class FrameExtractorWeb implements FrameExtractorPlatform {
  @override
  Future<double> getVideoDuration({required String videoPath, Uint8List? videoBytes}) async {
    if (videoBytes == null || videoBytes.isEmpty) {
      return 60.0;
    }

    final jsArray = videoBytes.toJS;
    final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'video/mp4'));
    final blobUrl = web.URL.createObjectURL(blob);

    try {
      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.preload = 'metadata';
      video.muted = true;
      video.playsInline = true;
      video.src = blobUrl;

      final completer = Completer<double>();
      video.onloadedmetadata = ((web.Event e) {
        if (!completer.isCompleted) {
          completer.complete(video.duration.toDouble());
        }
      }).toJS;

      video.onerror = ((web.Event e) {
        if (!completer.isCompleted) {
          completer.complete(60.0);
        }
      }).toJS;

      // Timeout safety
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => 60.0,
      );
    } finally {
      web.URL.revokeObjectURL(blobUrl);
    }
  }

  @override
  Future<List<Uint8List>> extractFrames({
    required String videoPath,
    Uint8List? videoBytes,
    required List<double> timestamps,
  }) async {
    if (videoBytes == null || videoBytes.isEmpty) {
      throw Exception('Video bytes are required on web platform.');
    }

    final jsArray = videoBytes.toJS;
    final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'video/mp4'));
    final blobUrl = web.URL.createObjectURL(blob);

    final frames = <Uint8List>[];

    try {
      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.preload = 'auto';
      video.muted = true;
      video.playsInline = true;
      video.src = blobUrl;

      final loadCompleter = Completer<void>();
      video.onloadeddata = ((web.Event e) {
        if (!loadCompleter.isCompleted) loadCompleter.complete();
      }).toJS;
      video.onerror = ((web.Event e) {
        if (!loadCompleter.isCompleted) {
          loadCompleter.completeError('Failed to load video on web');
        }
      }).toJS;

      await loadCompleter.future.timeout(const Duration(seconds: 15));

      final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      final width = video.videoWidth > 0 ? video.videoWidth : 1280;
      final height = video.videoHeight > 0 ? video.videoHeight : 720;
      canvas.width = width;
      canvas.height = height;
      final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;

      for (final t in timestamps) {
        final seekCompleter = Completer<void>();
        video.onseeked = ((web.Event e) {
          if (!seekCompleter.isCompleted) seekCompleter.complete();
        }).toJS;

        video.currentTime = t;
        await seekCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {},
        );

        ctx.drawImage(video, 0, 0);
        final dataUrl = canvas.toDataURL('image/jpeg', 0.9.toJS);
        final commaIndex = dataUrl.indexOf(',');
        final base64Str = commaIndex != -1 ? dataUrl.substring(commaIndex + 1) : dataUrl;
        final bytes = base64Decode(base64Str);
        frames.add(bytes);
      }
    } finally {
      web.URL.revokeObjectURL(blobUrl);
    }

    return frames;
  }
}

FrameExtractorPlatform getPlatformExtractor() => FrameExtractorWeb();
