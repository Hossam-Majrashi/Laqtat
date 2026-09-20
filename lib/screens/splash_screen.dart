import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_splash_screen.dart';
import 'desktop/desktop_splash_screen.dart';
import 'web/web_splash_screen.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SplashScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileSplashScreen(onNext: onNext),
      desktop: (_) => DesktopSplashScreen(onNext: onNext),
      web: (_) => WebSplashScreen(onNext: onNext),
    );
  }
}
