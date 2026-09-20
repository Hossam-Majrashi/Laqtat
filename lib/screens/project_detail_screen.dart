import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/video_grid_service.dart';
import '../services/settings_service.dart';
import '../utils/platform_utils.dart';
import 'mobile/mobile_project_detail_screen.dart';
import 'desktop/desktop_project_detail_screen.dart';
import 'web/web_project_detail_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.buildAdaptive(
      mobile: (_) => MobileProjectDetailScreen(
        project: project,
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
      desktop: (_) => DesktopProjectDetailScreen(
        project: project,
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
      web: (_) => WebProjectDetailScreen(
        project: project,
        projectService: projectService,
        videoGridService: videoGridService,
        settingsService: settingsService,
      ),
    );
  }
}
