import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../project_detail_screen.dart';
import 'desktop_settings_screen.dart';

class DesktopHomeScreen extends StatefulWidget {
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const DesktopHomeScreen({
    super.key,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  int _selectedNavIndex = 0;
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

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (!_isProcessing) _handleNewProject();
        },
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
          if (!_isProcessing) _handleNewProject();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              // Desktop Side Navigation Rail
              NavigationRail(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (idx) => setState(() => _selectedNavIndex = idx),
                backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_view_rounded, color: AppTheme.primaryAccent, size: 24),
                  ),
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.video_library_outlined),
                    selectedIcon: const Icon(Icons.video_library_rounded),
                    label: Text(l10n.projects),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings_rounded),
                    label: Text(l10n.settings),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),

              // Content Area
              Expanded(
                child: Stack(
                  children: [
                    _selectedNavIndex == 0
                        ? _buildProjectsView(context, l10n, isDark)
                        : DesktopSettingsScreen(
                            settingsService: widget.settingsService,
                            projectService: widget.projectService,
                          ),
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Card(
                            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: AppTheme.primaryAccent),
                                  const SizedBox(height: 20),
                                  Text(
                                    _statusMessage ?? l10n.processingVideo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsView(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and "New Project" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.projects,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _handleNewProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text('${l10n.newProject} (Ctrl+N)'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Drag-and-drop / Click Import Dropzone
          InkWell(
            onTap: _isProcessing ? null : _handleNewProject,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: AppTheme.primaryAccent, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.importVideoPrompt,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.supportedFormats,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Projects List / Grid
          Expanded(
            child: ListenableBuilder(
              listenable: widget.projectService,
              builder: (context, _) {
                final projects = widget.projectService.projects;

                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 64,
                          color: isDark ? const Color(0xFF3B3F48) : const Color(0xFFC0C2CB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noProjectsTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 440,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _buildDesktopProjectCard(context, project, l10n, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProjectCard(
    BuildContext context,
    Project project,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
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
            Expanded(
              child: project.gridImageBytes != null
                  ? Image.memory(
                      project.gridImageBytes!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: isDark ? AppTheme.darkCard : const Color(0xFFEDEBF0),
                      child: const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.videoName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.videoDuration}: ${project.formattedDuration} • ${project.dateCreated.day}/${project.dateCreated.month}/${project.dateCreated.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    tooltip: l10n.delete,
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
