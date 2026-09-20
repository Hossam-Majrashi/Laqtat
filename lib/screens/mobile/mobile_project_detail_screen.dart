import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';

class MobileProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const MobileProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<MobileProjectDetailScreen> createState() => _MobileProjectDetailScreenState();
}

class _MobileProjectDetailScreenState extends State<MobileProjectDetailScreen> {
  late Project _project;
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _regenerate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isProcessing = true;
      _statusMessage = l10n.processingVideo;
    });

    try {
      final updated = await widget.videoGridService.regenerateProject(
        project: _project,
        quality: widget.settingsService.gridQuality,
        exportFormat: widget.settingsService.defaultExportFormat,
      );
      await widget.projectService.saveProject(updated);
      if (mounted) {
        setState(() {
          _project = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.framesExtracted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _export(String format) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isProcessing = true;
      _statusMessage = l10n.generatingGrid;
    });

    try {
      final success = await widget.videoGridService.exportGrid(
        project: _project,
        format: format,
        saveLocation: widget.settingsService.defaultSaveLocation,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.exportSuccess : l10n.exportFailed),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.deleteProjectConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.projectService.deleteProject(_project.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.videoName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: l10n.delete,
            onPressed: _isProcessing ? null : _delete,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Grid Image Viewer with Interactive zoom
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: _project.gridImageBytes != null
                        ? InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _project.gridImageBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppTheme.primaryAccent),
                            const SizedBox(height: 16),
                            Text(
                              _statusMessage ?? l10n.processingVideo,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Metadata Card & Timestamps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.primaryAccent),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.videoDuration}: ${_project.formattedDuration}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${l10n.dateCreated}: ${_project.dateCreated.day}/${_project.dateCreated.month}/${_project.dateCreated.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Timestamps chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _project.timestamps.map((t) {
                        final mins = t ~/ 60;
                        final secs = (t % 60).toStringAsFixed(1);
                        final label = '${mins.toString().padLeft(2, '0')}:${secs.padLeft(4, '0')}';
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Chip(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            label: Text(label, style: const TextStyle(fontSize: 11)),
                            backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFEFEFF4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons: Regenerate & Export (PNG/JPG)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _regenerate,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(l10n.regenerate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            popupMenuTheme: PopupMenuThemeData(
                              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                ),
                              ),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            enabled: !_isProcessing,
                            tooltip: l10n.export,
                            position: PopupMenuPosition.over,
                            onSelected: (format) => _export(format),
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'png',
                                child: Row(
                                  children: [
                                    const Icon(Icons.image_outlined, color: AppTheme.primaryAccent, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.exportPng,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: 'jpg',
                                child: Row(
                                  children: [
                                    const Icon(Icons.image_rounded, color: AppTheme.primaryAccent, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.exportJpg,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.export,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_up_rounded, size: 20, color: Colors.white70),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
