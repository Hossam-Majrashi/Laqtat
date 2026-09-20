import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppPlatformType { mobile, desktop, web }

class PlatformUtils {
  static AppPlatformType get currentPlatform {
    if (kIsWeb) return AppPlatformType.web;
    try {
      if (io.Platform.isLinux || io.Platform.isMacOS || io.Platform.isWindows) {
        return AppPlatformType.desktop;
      }
    } catch (_) {}
    return AppPlatformType.mobile;
  }

  static bool get isMobile => currentPlatform == AppPlatformType.mobile;
  static bool get isDesktop => currentPlatform == AppPlatformType.desktop;
  static bool get isWeb => currentPlatform == AppPlatformType.web;

  static Widget buildAdaptive({
    required WidgetBuilder mobile,
    required WidgetBuilder desktop,
    required WidgetBuilder web,
  }) {
    return Builder(
      builder: (context) {
        if (kIsWeb) return web(context);
        if (isDesktop) return desktop(context);
        return mobile(context);
      },
    );
  }
}
