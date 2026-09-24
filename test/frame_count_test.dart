import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laqtat/models/project.dart';
import 'package:laqtat/services/grid_compositor.dart';
import 'package:laqtat/services/video_grid_service.dart';
import 'package:laqtat/services/settings_service.dart';

void main() {
  group('Sampling logic: generateTimestamps for N in {4, 8, 16}', () {
    final service = VideoGridService();
    const duration = 100.0;

    test('N = 4 evenly spaced timestamps: duration/(N+1) * [1..N]', () {
      final timestamps = service.generateTimestamps(duration, frameCount: 4);
      expect(timestamps.length, 4);
      const step = duration / 5.0; // 20.0
      for (int i = 0; i < 4; i++) {
        expect(timestamps[i], closeTo((i + 1) * step, 0.001));
      }
      expect(timestamps, [20.0, 40.0, 60.0, 80.0]);
    });

    test('N = 8 evenly spaced timestamps: duration/(N+1) * [1..N] (matches legacy default)', () {
      final timestamps = service.generateTimestamps(duration, frameCount: 8);
      expect(timestamps.length, 8);
      const step = duration / 9.0;
      for (int i = 0; i < 8; i++) {
        expect(timestamps[i], closeTo((i + 1) * step, 0.001));
      }
    });

    test('N = 16 evenly spaced timestamps: duration/(N+1) * [1..N]', () {
      final timestamps = service.generateTimestamps(duration, frameCount: 16);
      expect(timestamps.length, 16);
      const step = duration / 17.0;
      for (int i = 0; i < 16; i++) {
        expect(timestamps[i], closeTo((i + 1) * step, 0.001));
      }
    });

    test('Regenerate re-samples N timestamps avoiding previous timestamps', () {
      for (final n in [4, 8, 16]) {
        final original = service.generateTimestamps(duration, frameCount: n);
        final regenerated = service.generateTimestamps(
          duration,
          frameCount: n,
          previousTimestamps: original,
        );
        expect(regenerated.length, n);
        // Ensure at least some timestamps differ due to jitter
        bool anyDifferent = false;
        for (int i = 0; i < n; i++) {
          if ((regenerated[i] - original[i]).abs() > 0.01) {
            anyDifferent = true;
          }
        }
        expect(anyDifferent, isTrue);
      }
    });

    test('Switching N generates fresh evenly spaced timestamps', () {
      final prev8 = service.generateTimestamps(duration, frameCount: 8);
      // Passing previous 8-frame timestamps when requesting 4 frames triggers fresh evenly spaced sampling
      final fresh4 = service.generateTimestamps(
        duration,
        frameCount: 4,
        previousTimestamps: prev8,
      );
      expect(fresh4.length, 4);
      expect(fresh4, [20.0, 40.0, 60.0, 80.0]);
    });
  });

  group('Grid layout adaptation & dimensions', () {
    test('getGridDimensions derives correct columns and rows', () {
      expect(GridCompositor.getGridDimensions(4), (2, 2));
      expect(GridCompositor.getGridDimensions(8), (4, 2));
      expect(GridCompositor.getGridDimensions(16), (4, 4));
    });

    test('Composed grid byte generation and dimension verification', () async {
      // Create a solid test frame
      final testImg = img.Image(width: 320, height: 180);
      img.fill(testImg, color: img.ColorRgb8(100, 150, 200));
      final frameBytes = Uint8List.fromList(img.encodePng(testImg));

      // N = 4: 2 cols x 2 rows
      final frames4 = List.generate(4, (_) => frameBytes);
      final grid4Bytes = await GridCompositor.composeGrid(
        frames: frames4,
        frameCount: 4,
        quality: 'standard',
        format: 'png',
      );
      final decoded4 = img.decodeImage(grid4Bytes)!;
      // 2 * 480 + 3 * 8 = 984, 2 * 270 + 3 * 8 = 564
      expect(decoded4.width, 984);
      expect(decoded4.height, 564);

      // N = 8: 4 cols x 2 rows (pixel-equivalent to legacy)
      final frames8 = List.generate(8, (_) => frameBytes);
      final grid8Bytes = await GridCompositor.composeGrid(
        frames: frames8,
        frameCount: 8,
        quality: 'standard',
        format: 'png',
      );
      final decoded8 = img.decodeImage(grid8Bytes)!;
      // 4 * 480 + 5 * 8 = 1960, 2 * 270 + 3 * 8 = 564
      expect(decoded8.width, 1960);
      expect(decoded8.height, 564);

      // N = 16: 4 cols x 4 rows
      final frames16 = List.generate(16, (_) => frameBytes);
      final grid16Bytes = await GridCompositor.composeGrid(
        frames: frames16,
        frameCount: 16,
        quality: 'standard',
        format: 'png',
      );
      final decoded16 = img.decodeImage(grid16Bytes)!;
      // 4 * 480 + 5 * 8 = 1960, 4 * 270 + 5 * 8 = 1120
      expect(decoded16.width, 1960);
      expect(decoded16.height, 1120);
    });
  });

  group('Project model frameCount persistence', () {
    test('Default frameCount is 8', () {
      final project = Project(
        id: 'test_1',
        title: 'Video',
        videoName: 'video.mp4',
        videoPath: '/path/video.mp4',
        dateCreated: DateTime.now(),
        durationSeconds: 60.0,
        gridImagePath: '',
        timestamps: [1, 2, 3, 4, 5, 6, 7, 8],
      );
      expect(project.frameCount, 8);
      final json = project.toJson();
      expect(json['frameCount'], 8);
    });

    test('Saves and restores explicit frameCount (4, 8, 16)', () {
      for (final n in [4, 8, 16]) {
        final project = Project(
          id: 'test_$n',
          title: 'Video',
          videoName: 'video.mp4',
          videoPath: '/path/video.mp4',
          dateCreated: DateTime.now(),
          durationSeconds: 60.0,
          gridImagePath: '',
          timestamps: List.generate(n, (i) => i.toDouble()),
          frameCount: n,
        );
        final json = project.toJson();
        expect(json['frameCount'], n);

        final restored = Project.fromJson(json);
        expect(restored.frameCount, n);
      }
    });

    test('Backward compatibility: json without frameCount derives from timestamps.length', () {
      final legacyJson = {
        'id': 'legacy_proj',
        'title': 'Legacy',
        'videoName': 'legacy.mp4',
        'videoPath': '',
        'dateCreated': DateTime.now().toIso8601String(),
        'durationSeconds': 100.0,
        'gridImagePath': '',
        'timestamps': [10.0, 20.0, 30.0, 40.0],
        'quality': 'standard',
        'exportFormat': 'png',
      };
      final restored = Project.fromJson(legacyJson);
      expect(restored.frameCount, 4);
    });
  });

  group('SettingsService defaultFrameCount', () {
    test('Default is 8 and can be changed to 4 or 16', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      expect(settings.defaultFrameCount, 8);

      await settings.setDefaultFrameCount(16);
      expect(settings.defaultFrameCount, 16);
      expect(prefs.getInt('default_frame_count'), 16);

      await settings.setDefaultFrameCount(4);
      expect(settings.defaultFrameCount, 4);
      expect(prefs.getInt('default_frame_count'), 4);
    });
  });
}
