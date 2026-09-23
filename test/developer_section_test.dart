import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laqtat/widgets/developer_section.dart';
import 'package:laqtat/l10n/app_localizations.dart';
import 'package:laqtat/services/settings_service.dart';
import 'package:laqtat/services/project_service.dart';
import 'package:laqtat/screens/mobile/mobile_settings_screen.dart';
import 'package:laqtat/screens/desktop/desktop_settings_screen.dart';
import 'package:laqtat/screens/web/web_settings_screen.dart';

void main() {
  testWidgets('DeveloperSection renders Arabic developer details', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ar'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeveloperSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حسام حسن مجرشي'), findsOneWidget);
    expect(find.text('Hossam.Majrashi@gmail.com'), findsOneWidget);
    expect(find.text('hossam-majrashi.github.io/Works/'), findsOneWidget);
    expect(find.text('المطور'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('الموقع الإلكتروني'), findsOneWidget);
  });

  testWidgets('DeveloperSection renders English developer details', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeveloperSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حسام حسن مجرشي'), findsOneWidget);
    expect(find.text('Hossam.Majrashi@gmail.com'), findsOneWidget);
    expect(find.text('hossam-majrashi.github.io/Works/'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
  });

  testWidgets('MobileSettingsScreen contains DeveloperSection at the end', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    final projectService = ProjectService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: MobileSettingsScreen(
          settingsService: settingsService,
          projectService: projectService,
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(find.byType(DeveloperSection), 300);

    expect(find.byType(DeveloperSection), findsOneWidget);
    expect(find.text('حسام حسن مجرشي'), findsOneWidget);
  });

  testWidgets('DesktopSettingsScreen contains DeveloperSection at the end', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    final projectService = ProjectService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: DesktopSettingsScreen(
          settingsService: settingsService,
          projectService: projectService,
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(find.byType(DeveloperSection), 300);

    expect(find.byType(DeveloperSection), findsOneWidget);
    expect(find.text('حسام حسن مجرشي'), findsOneWidget);
  });

  testWidgets('WebSettingsScreen contains DeveloperSection at the end', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    final projectService = ProjectService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: WebSettingsScreen(
          settingsService: settingsService,
          projectService: projectService,
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(find.byType(DeveloperSection), 300);

    expect(find.byType(DeveloperSection), findsOneWidget);
    expect(find.text('حسام حسن مجرشي'), findsOneWidget);
  });
}
