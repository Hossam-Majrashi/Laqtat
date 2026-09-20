import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_theme_screen.dart';
import 'desktop/desktop_theme_screen.dart';
import 'web/web_theme_screen.dart';

class ThemeScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onFinishOnboarding;
  final VoidCallback? onBack;

  const ThemeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onFinishOnboarding,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileThemeScreen(
        currentThemeMode: currentThemeMode,
        onThemeChanged: onThemeChanged,
        onFinishOnboarding: onFinishOnboarding,
        onBack: onBack,
      ),
      desktop: (_) => DesktopThemeScreen(
        currentThemeMode: currentThemeMode,
        onThemeChanged: onThemeChanged,
        onFinishOnboarding: onFinishOnboarding,
        onBack: onBack,
      ),
      web: (_) => WebThemeScreen(
        currentThemeMode: currentThemeMode,
        onThemeChanged: onThemeChanged,
        onFinishOnboarding: onFinishOnboarding,
        onBack: onBack,
      ),
    );
  }
}
