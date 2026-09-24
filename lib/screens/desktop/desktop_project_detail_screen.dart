import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';

class DesktopProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const DesktopProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<DesktopProjectDetailScreen> createState() => _DesktopProjectDetailScreenState();
}

class _DesktopProjectDetailScreenState extends State<DesktopProjectDetailScreen> {
  late Project _project;
  final TransformationController _transformController = TransformationController();
  bool _isProcessing = false;
  String? _statusMessage;
  late int _selectedFrameCount;
  late String _selectedQuality;
  late String _selectedFormat;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _selectedFrameCount = widget.project.frameCount;
    _selectedQuality = widget.project.quality;
    _selectedFormat = widget.settingsService.defaultExportFormat;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _changeFrameCount(int newCount) async {
    if (newCount == _selectedFrameCount || _isProcessing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedFrameCount = newCount;
      _isProcessing = true;
      _statusMessage = l10n.processingVideo(newCount);
    });

    try {
      final updated = await widget.videoGridService.regenerateProject(
        project: _project,
        frameCount: newCount,
        quality: _selectedQuality,
        exportFormat: _selectedFormat,
        isNewGenerate: true,
      );
      await widget.projectService.saveProject(updated);
      if (mounted) {
        setState(() {
          _project = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.framesExtracted(newCount))),
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

  Future<void> _regenerate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isProcessing = true;
      _statusMessage = l10n.processingVideo(_selectedFrameCount);
    });

    try {
      final updated = await widget.videoGridService.regenerateProject(
        project: _project,
        frameCount: _selectedFrameCount,
        quality: _selectedQuality,
        exportFormat: _selectedFormat,
        isNewGenerate: false,
      );
      await widget.projectService.saveProject(updated);
      if (mounted) {
        setState(() {
          _project = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.framesExtracted(_selectedFrameCount))),
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

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyR): () {
          if (!_isProcessing) _regenerate();
        },
        const SingleActivator(LogicalKeyboardKey.keyE): () {
          if (!_isProcessing) _export(_selectedFormat);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_project.videoName),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                label: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
                onPressed: _isProcessing ? null : _delete,
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Row(
            children: [
              // Main Viewer Pane
              Expanded(
                flex: 7,
                child: Container(
                  color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                  child: Stack(
                    children: [
                      Center(
                        child: _project.gridImageBytes != null
                            ? InteractiveViewer(
                                transformationController: _transformController,
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Card(
                                    elevation: 8,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                      ),
                                    ),
                                    child: Image.memory(
                                      _project.gridImageBytes!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      // Floating zoom controls
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Card(
                          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.zoom_out_rounded, size: 20),
                                tooltip: 'Zoom Out',
                                onPressed: () {
                                  _transformController.value = Matrix4.identity();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
                                tooltip: 'Reset Zoom',
                                onPressed: () {
                                  _transformController.value = Matrix4.identity();
                                },
                              ),
                            ],
                          ),
                        ),
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
                                  _statusMessage ?? l10n.processingVideo(_selectedFrameCount),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Side Control & Metadata Pane
              Container(
                width: 340,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  border: Border(
                    left: BorderSide(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.projectDetails,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.movie_outlined, l10n.appName, _project.videoName),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.timer_outlined, l10n.videoDuration, _project.formattedDuration),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              l10n.dateCreated,
                              '${_project.dateCreated.day}/${_project.dateCreated.month}/${_project.dateCreated.year}',
                            ),
                            const Divider(height: 32),
                            Text(
                              l10n.framesExtracted(_project.frameCount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _project.timestamps.map((t) {
                                final mins = t ~/ 60;
                                final secs = (t % 60).toStringAsFixed(1);
                                final label = '${mins.toString().padLeft(2, '0')}:${secs.padLeft(4, '0')}';
                                return Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(label, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFF0EFF4),
                                );
                              }).toList(),
                            ),
                            const Divider(height: 24),
                            Text(
                              l10n.frameCount,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<int>(
                              segments: const [
                                ButtonSegment(value: 4, label: Text('4')),
                                ButtonSegment(value: 8, label: Text('8')),
                                ButtonSegment(value: 16, label: Text('16')),
                              ],
                              selected: {_selectedFrameCount},
                              onSelectionChanged: _isProcessing
                                  ? null
                                  : (set) => _changeFrameCount(set.first),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.exportQuality,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(value: 'standard', label: Text(l10n.standardQuality.split(' ').first)),
                                ButtonSegment(value: 'high', label: Text(l10n.highQuality.split(' ').first)),
                              ],
                              selected: {_selectedQuality},
                              onSelectionChanged: (set) {
                                setState(() => _selectedQuality = set.first);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Regenerate Action
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _regenerate,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('${l10n.regenerate} (R)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Export Actions (both PNG and JPG required per §2)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => _export('png'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('PNG'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => _export('jpg'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFE4E3EA),
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('JPG'),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryAccent),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
