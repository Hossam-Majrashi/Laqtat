import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../project_detail_screen.dart';
import 'web_settings_screen.dart';

class WebHomeScreen extends StatefulWidget {
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const WebHomeScreen({
    super.key,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
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
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentTab,
                  onDestinationSelected: (i) => setState(() => _currentTab = i),
                  backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grid_view_rounded, color: AppTheme.primaryAccent, size: 22),
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
                Expanded(
                  child: Stack(
                    children: [
                      _currentTab == 0
                          ? _buildProjectsView(context, l10n, isDark, true)
                          : WebSettingsScreen(
                              settingsService: widget.settingsService,
                              projectService: widget.projectService,
                            ),
                      if (_isProcessing) _buildLoadingOverlay(isDark, l10n),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                IndexedStack(
                  index: _currentTab,
                  children: [
                    _buildProjectsView(context, l10n, isDark, false),
                    WebSettingsScreen(
                      settingsService: widget.settingsService,
                      projectService: widget.projectService,
                    ),
                  ],
                ),
                if (_isProcessing) _buildLoadingOverlay(isDark, l10n),
              ],
            ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (i) => setState(() => _currentTab = i),
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
      floatingActionButton: (!isWide && _currentTab == 0)
          ? FloatingActionButton.extended(
              onPressed: _isProcessing ? null : _handleNewProject,
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(l10n.newProject),
            )
          : null,
    );
  }

  Widget _buildLoadingOverlay(bool isDark, AppLocalizations l10n) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
    );
  }

  Widget _buildProjectsView(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isWide,
  ) {
    return Padding(
      padding: EdgeInsets.all(isWide ? 28.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Web Storage Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primaryAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.webStorageNotice,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.projects,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isWide)
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _handleNewProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.newProject),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Dropzone / Import Card
          InkWell(
            onTap: _isProcessing ? null : _handleNewProject,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_upload_outlined, color: AppTheme.primaryAccent, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.importVideoPrompt, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(l10n.supportedFormats, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

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
                        Icon(Icons.grid_view_rounded, size: 56, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(l10n.noProjectsTitle, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isWide ? 400 : 600,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: isWide ? 1.5 : 1.7,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _buildWebProjectCard(context, project, l10n, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebProjectCard(
    BuildContext context,
    Project project,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                      child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.videoName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${l10n.videoDuration}: ${project.formattedDuration}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
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
