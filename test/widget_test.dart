import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laqtat/main.dart';
import 'package:laqtat/services/settings_service.dart';
import 'package:laqtat/services/project_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Onboarding flow and persistence verification', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    final projectService = ProjectService();
    await projectService.init();

    // 1. First Launch: Must show Splash / About screen
    await tester.pumpWidget(LaqtatApp(
      settingsService: settingsService,
      projectService: projectService,
    ));
    await tester.pumpAndSettle();

    expect(settingsService.isOnboardingComplete, false);
    // Finds Next button on Splash screen
    final nextBtn1 = find.byType(ElevatedButton);
    expect(nextBtn1, findsOneWidget);

    // Tap Next to advance to Language screen
    await tester.tap(nextBtn1);
    await tester.pumpAndSettle();

    // 2. Language selection screen: Test Arabic and English switching
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('English'), findsWidgets);

    // Switch to English
    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();
    expect(settingsService.languageCode, 'en');

    // Tap Next to advance to Theme screen
    final nextBtn2 = find.widgetWithText(ElevatedButton, 'Next');
    await tester.tap(nextBtn2);
    await tester.pumpAndSettle();

    // 3. Theme selection screen: user picks Dark or Light
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);

    // Select Light Mode
    await tester.tap(find.text('Light Mode'));
    await tester.pumpAndSettle();
    expect(settingsService.themeMode, ThemeMode.light);

    // Finish Onboarding
    final getStartedBtn = find.text('Get Started');
    expect(getStartedBtn, findsOneWidget);
    await tester.tap(getStartedBtn);
    await tester.pumpAndSettle();

    // 4. Persistence verification: onboarding_complete must be true in SharedPreferences
    expect(settingsService.isOnboardingComplete, true);
    expect(prefs.getBool('onboarding_complete'), true);

    // Verify Home / Projects screen is shown
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // 5. Subsequent launch verification:
    // When app is re-created with the persisted preferences, it must go straight to Home!
    final secondLaunchSettings = SettingsService(prefs);
    expect(secondLaunchSettings.isOnboardingComplete, true);

    await tester.pumpWidget(LaqtatApp(
      settingsService: secondLaunchSettings,
      projectService: projectService,
    ));
    await tester.pumpAndSettle();

    // Must show Home directly, NOT Splash
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Get Started'), findsNothing);
  });

  testWidgets('RTL and Arabic localization verification', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'language_code': 'ar',
      'theme_mode': 'dark',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    final projectService = ProjectService();
    await projectService.init();

    await tester.pumpWidget(LaqtatApp(
      settingsService: settingsService,
      projectService: projectService,
    ));
    await tester.pumpAndSettle();

    // Verify Arabic strings are rendered
    expect(find.text('لقطات'), findsWidgets);
    expect(find.text('المشاريع'), findsWidgets);
    expect(find.text('الإعدادات'), findsWidgets);

    // Verify Directionality is RTL
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
