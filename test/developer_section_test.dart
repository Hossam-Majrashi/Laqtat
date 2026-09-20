import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqtat/widgets/developer_section.dart';
import 'package:laqtat/l10n/app_localizations.dart';

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
}
