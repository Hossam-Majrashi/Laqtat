import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laqtat/l10n/app_localizations.dart';
import 'package:laqtat/models/project.dart';
import 'package:laqtat/screens/desktop/desktop_project_detail_screen.dart';
import 'package:laqtat/screens/mobile/mobile_project_detail_screen.dart';
import 'package:laqtat/screens/web/web_project_detail_screen.dart';
import 'package:laqtat/services/project_service.dart';
import 'package:laqtat/services/settings_service.dart';
import 'package:laqtat/services/video_grid_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;
  late ProjectService projectService;
  late VideoGridService videoGridService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs);
    projectService = ProjectService();
    await projectService.init();
    videoGridService = VideoGridService();
  });

  Widget wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  Project createTestProject({int frameCount = 8}) {
    return Project(
      id: 'test_proj',
      title: 'Demo Video',
      videoName: 'sample.mp4',
      videoPath: '/path/sample.mp4',
      dateCreated: DateTime(2026, 9, 25),
      durationSeconds: 120.0,
      gridImagePath: '',
      timestamps: List.generate(frameCount, (i) => (i + 1) * 10.0),
      frameCount: frameCount,
      quality: 'standard',
      exportFormat: 'png',
      gridImageBytes: null,
    );
  }

  group('Desktop UI parity & frame count selector', () {
    testWidgets('Desktop detail screen renders frame count selector with 4, 8, 16', (tester) async {
      final project = createTestProject(frameCount: 8);
      await tester.pumpWidget(wrapWithApp(
        DesktopProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('Frame Count'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('8'), findsWidgets);
      expect(find.text('16'), findsWidgets);
      expect(find.text('8 frames extracted'), findsOneWidget);
    });

    testWidgets('Desktop detail screen shows correct initial state for N=16', (tester) async {
      final project = createTestProject(frameCount: 16);
      await tester.pumpWidget(wrapWithApp(
        DesktopProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('16 frames extracted'), findsOneWidget);
      final segmentedButton = tester.widget<SegmentedButton<int>>(
        find.widgetWithText(SegmentedButton<int>, '16'),
      );
      expect(segmentedButton.selected, {16});
    });
  });

  group('Web UI parity & frame count selector', () {
    testWidgets('Web detail screen renders frame count selector with 4, 8, 16', (tester) async {
      final project = createTestProject(frameCount: 8);
      await tester.pumpWidget(wrapWithApp(
        WebProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('Frame Count'), findsWidgets);
      expect(find.text('4'), findsWidgets);
      expect(find.text('8'), findsWidgets);
      expect(find.text('16'), findsWidgets);
      expect(find.text('8 frames extracted'), findsWidgets);
    });

    testWidgets('Web detail screen shows correct initial state for N=4', (tester) async {
      final project = createTestProject(frameCount: 4);
      await tester.pumpWidget(wrapWithApp(
        WebProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('4 frames extracted'), findsWidgets);
      final segmentedButton = tester.widget<SegmentedButton<int>>(
        find.widgetWithText(SegmentedButton<int>, '4').first,
      );
      expect(segmentedButton.selected, {4});
    });
  });

  group('Mobile UI parity & frame count selector', () {
    testWidgets('Mobile detail screen renders frame count selector with 4, 8, 16', (tester) async {
      final project = createTestProject(frameCount: 8);
      await tester.pumpWidget(wrapWithApp(
        MobileProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('Frame Count'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('8'), findsWidgets);
      expect(find.text('16'), findsWidgets);
      expect(find.text('8 frames extracted'), findsOneWidget);
    });

    testWidgets('Mobile detail screen shows correct initial state for N=16', (tester) async {
      final project = createTestProject(frameCount: 16);
      await tester.pumpWidget(wrapWithApp(
        MobileProjectDetailScreen(
          project: project,
          projectService: projectService,
          videoGridService: videoGridService,
          settingsService: settingsService,
        ),
      ));
      await tester.pump();

      expect(find.text('16 frames extracted'), findsOneWidget);
      final segmentedButton = tester.widget<SegmentedButton<int>>(
        find.widgetWithText(SegmentedButton<int>, '16'),
      );
      expect(segmentedButton.selected, {16});
    });
  });

  group('ICU Localization dynamic strings (Arabic & English)', () {
    testWidgets('Arabic ICU plural strings for 4, 8, 16', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              l10n = AppLocalizations.of(ctx)!;
              return Container();
            },
          ),
        ),
      );
      await tester.pump();

      // ICU plural in Arabic: 4 and 8 use few (لقطات), 16 uses many (لقطة)
      expect(l10n.framesExtracted(4), 'تم استخراج 4 لقطات');
      expect(l10n.framesExtracted(8), 'تم استخراج 8 لقطات');
      expect(l10n.framesExtracted(16), 'تم استخراج 16 لقطة');

      expect(l10n.processingVideo(4), 'جاري استخراج 4 لقطات من الفيديو...');
      expect(l10n.processingVideo(8), 'جاري استخراج 8 لقطات من الفيديو...');
      expect(l10n.processingVideo(16), 'جاري استخراج 16 لقطة من الفيديو...');

      expect(l10n.frameCount, 'عدد اللقطات');
    });

    testWidgets('English ICU plural strings for 4, 8, 16', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              l10n = AppLocalizations.of(ctx)!;
              return Container();
            },
          ),
        ),
      );
      await tester.pump();

      expect(l10n.framesExtracted(4), '4 frames extracted');
      expect(l10n.framesExtracted(8), '8 frames extracted');
      expect(l10n.framesExtracted(16), '16 frames extracted');

      expect(l10n.processingVideo(4), 'Extracting 4 frames from video...');
      expect(l10n.processingVideo(8), 'Extracting 8 frames from video...');
      expect(l10n.processingVideo(16), 'Extracting 16 frames from video...');

      expect(l10n.frameCount, 'Frame Count');
    });
  });
}
