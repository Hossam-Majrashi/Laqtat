import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../project_detail_screen.dart';
import 'mobile_settings_screen.dart';

class MobileHomeScreen extends StatefulWidget {
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const MobileHomeScreen({
    super.key,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _currentTab = 0;
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _handleNewProject() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await widget.videoGridService.pickVideo();
      if (file == null) return;

      setState(() {
        _isProcessing = true;
        _statusMessage = l10n.processingVideo;
      });

      final project = await widget.videoGridService.processVideo(
        file: file,
        quality: widget.settingsService.gridQuality,
        exportFormat: widget.settingsService.defaultExportFormat,
      );

      await widget.projectService.saveProject(project);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });

        // Navigate to project detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(
              project: project,
              projectService: widget.projectService,
              videoGridService: widget.videoGridService,
              settingsService: widget.settingsService,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });

        String errorMsg;
        final errString = e.toString();
        if (errString.contains('UNSUPPORTED_FORMAT')) {
          errorMsg = l10n.unsupportedVideoFormat;
        } else if (errString.contains('FFMPEG_NOT_FOUND')) {
          errorMsg = l10n.ffmpegNotFound;
        } else {
          errorMsg = l10n.errorLoadingVideo;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: [
              _buildProjectsTab(context, l10n, isDark),
              MobileSettingsScreen(
                settingsService: widget.settingsService,
                projectService: widget.projectService,
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primaryAccent),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage ?? l10n.processingVideo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: _isProcessing ? null : _handleNewProject,
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(l10n.newProject),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.projects,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: AppTheme.primaryAccent, size: 24),
            const SizedBox(width: 8),
            Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.projectService,
        builder: (context, _) {
          final projects = widget.projectService.projects;
          if (projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 72,
                      color: isDark ? const Color(0xFF4A4E57) : const Color(0xFFB4B6BE),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.noProjectsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noProjectsSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? const Color(0xFFA2A5AD) : const Color(0xFF686E77),
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleNewProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      icon: const Icon(Icons.video_call_rounded),
                      label: Text(l10n.importVideo),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 84),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _buildProjectCard(context, project, l10n, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                project: project,
                projectService: widget.projectService,
                videoGridService: widget.videoGridService,
                settingsService: widget.settingsService,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4x2 Grid preview
            if (project.gridImageBytes != null)
              AspectRatio(
                aspectRatio: 16 / 4.6, // 4x2 grid aspect ratio
                child: Image.memory(
                  project.gridImageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            else
              Container(
                height: 100,
                color: isDark ? AppTheme.darkCard : const Color(0xFFEBEAEF),
                child: const Center(
                  child: Icon(Icons.grid_view_rounded, size: 36, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.videoName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${l10n.videoDuration}: ${project.formattedDuration}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${project.dateCreated.day}/${project.dateCreated.month}/${project.dateCreated.year}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.deleteProject),
                          content: Text(l10n.deleteProjectConfirmation),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await widget.projectService.deleteProject(project.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
