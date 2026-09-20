import 'package:flutter/material.dart';
import '../services/project_service.dart';
import '../services/video_grid_service.dart';
import '../services/settings_service.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_home_screen.dart';
import 'desktop/desktop_home_screen.dart';
import 'web/web_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const HomeScreen({
    super.key,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileHomeScreen(
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
      desktop: (_) => DesktopHomeScreen(
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
      web: (_) => WebHomeScreen(
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
    );
  }
}
