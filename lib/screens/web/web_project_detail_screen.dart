import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/video_grid_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';

class WebProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectService projectService;
  final VideoGridService videoGridService;
  final SettingsService settingsService;

  const WebProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectService,
    required this.videoGridService,
    required this.settingsService,
  });

  @override
  State<WebProjectDetailScreen> createState() => _WebProjectDetailScreenState();
}

class _WebProjectDetailScreenState extends State<WebProjectDetailScreen> {
  late Project _project;
  final TransformationController _transformController = TransformationController();
  bool _isProcessing = false;
  String? _statusMessage;
  late String _selectedQuality;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _selectedQuality = widget.settingsService.gridQuality;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
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
        quality: _selectedQuality,
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
    final isWide = MediaQuery.of(context).size.width > 850;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.videoName),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            label: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
            onPressed: _isProcessing ? null : _delete,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isWide ? _buildWideLayout(context, l10n, isDark) : _buildCompactLayout(context, l10n, isDark),
    );
  }

  Widget _buildWideLayout(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _buildImageViewer(isDark),
        ),
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            border: Border(
              left: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: _buildSidebarControls(context, l10n, isDark),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: _buildImageViewer(isDark),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            border: Border(
              top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: _buildCompactControls(context, l10n, isDark),
        ),
      ],
    );
  }

  Widget _buildImageViewer(bool isDark) {
    return Stack(
      children: [
        Center(
          child: _project.gridImageBytes != null
              ? InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 6,
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
                    _statusMessage ?? 'Processing...',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarControls(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.projectDetails, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('${l10n.videoDuration}: ${_project.formattedDuration}', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          '${l10n.dateCreated}: ${_project.dateCreated.day}/${_project.dateCreated.month}/${_project.dateCreated.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 24),
        Text(l10n.framesExtracted, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _project.timestamps.map((t) {
            final mins = t ~/ 60;
            final secs = (t % 60).toStringAsFixed(1);
            final label = '${mins.toString().padLeft(2, '0')}:${secs.padLeft(4, '0')}';
            return Chip(
              visualDensity: VisualDensity.compact,
              label: Text(label, style: const TextStyle(fontSize: 10)),
              backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFF0EFF4),
            );
          }).toList(),
        ),
        const Divider(height: 24),
        Text(l10n.exportQuality, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
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
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _regenerate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.regenerate),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _export('png'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('PNG'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _export('jpg'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFE4E3EA),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('JPG'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactControls(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${l10n.videoDuration}: ${_project.formattedDuration}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              '${_project.dateCreated.day}/${_project.dateCreated.month}/${_project.dateCreated.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _regenerate,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.regenerate),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _export('png'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(l10n.exportPng),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
