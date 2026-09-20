import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/project_service.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_settings_screen.dart';
import 'desktop/desktop_settings_screen.dart';
import 'web/web_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final ProjectService projectService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.projectService,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileSettingsScreen(
        settingsService: settingsService,
        projectService: projectService,
      ),
      desktop: (_) => DesktopSettingsScreen(
        settingsService: settingsService,
        projectService: projectService,
      ),
      web: (_) => WebSettingsScreen(
        settingsService: settingsService,
        projectService: projectService,
      ),
    );
  }
}
