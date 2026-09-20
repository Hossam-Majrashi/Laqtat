import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_language_screen.dart';
import 'desktop/desktop_language_screen.dart';
import 'web/web_language_screen.dart';

class LanguageScreen extends StatelessWidget {
  final String currentLanguageCode;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const LanguageScreen({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileLanguageScreen(
        currentLanguageCode: currentLanguageCode,
        onLanguageSelected: onLanguageSelected,
        onNext: onNext,
        onBack: onBack,
      ),
      desktop: (_) => DesktopLanguageScreen(
        currentLanguageCode: currentLanguageCode,
        onLanguageSelected: onLanguageSelected,
        onNext: onNext,
        onBack: onBack,
      ),
      web: (_) => WebLanguageScreen(
        currentLanguageCode: currentLanguageCode,
        onLanguageSelected: onLanguageSelected,
        onNext: onNext,
        onBack: onBack,
      ),
    );
  }
}
