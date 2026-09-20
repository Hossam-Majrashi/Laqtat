import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_language.dart';
import '../../services/settings_service.dart';
import '../../services/project_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/platform_utils.dart';
import '../../widgets/developer_section.dart';

class MobileSettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final ProjectService projectService;

  const MobileSettingsScreen({
    super.key,
    required this.settingsService,
    required this.projectService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // Language Switcher
              _buildSectionHeader(context, l10n.language),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: AppLanguage.supportedLanguages.map((lang) {
                      final isSelected = lang.id == settingsService.languageCode;
                      return RadioListTile<String>(
                        title: Text(lang.nativeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lang.name),
                        value: lang.id,
                        groupValue: settingsService.languageCode,
                        activeColor: AppTheme.primaryAccent,
                        onChanged: (val) {
                          if (val != null) settingsService.setLanguageCode(val);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Theme Switcher (exact colors)
              _buildSectionHeader(context, l10n.theme),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.darkMode),
                      subtitle: const Text('#212327 / #232627'),
                      value: ThemeMode.dark,
                      groupValue: settingsService.themeMode,
                      activeColor: AppTheme.primaryAccent,
                      secondary: const Icon(Icons.dark_mode_rounded),
                      onChanged: (mode) {
                        if (mode != null) settingsService.setThemeMode(mode);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.lightMode),
                      subtitle: const Text('#efeef1 / #fefefe'),
                      value: ThemeMode.light,
                      groupValue: settingsService.themeMode,
                      activeColor: AppTheme.primaryAccent,
                      secondary: const Icon(Icons.light_mode_rounded),
                      onChanged: (mode) {
                        if (mode != null) settingsService.setThemeMode(mode);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Export Defaults
              _buildSectionHeader(context, l10n.export),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.defaultExportFormat),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'png', label: Text('PNG')),
                          ButtonSegment(value: 'jpg', label: Text('JPG')),
                        ],
                        selected: {settingsService.defaultExportFormat},
                        onSelectionChanged: (set) {
                          settingsService.setDefaultExportFormat(set.first);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.exportQuality),
                      subtitle: Text(settingsService.gridQuality == 'high'
                          ? l10n.highQuality
                          : l10n.standardQuality),
                      trailing: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'standard', label: Text(l10n.standardQuality.split(' ').first)),
                          ButtonSegment(value: 'high', label: Text(l10n.highQuality.split(' ').first)),
                        ],
                        selected: {settingsService.gridQuality},
                        onSelectionChanged: (set) {
                          settingsService.setGridQuality(set.first);
                        },
                      ),
                    ),
                    if (!PlatformUtils.isWeb) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: Text(l10n.defaultSaveLocation),
                        subtitle: Text(
                          settingsService.defaultSaveLocation ?? l10n.systemDefault,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.folder_open_rounded),
                          onPressed: () async {
                            final path = await FilePicker.getDirectoryPath();
                            if (path != null) {
                              settingsService.setDefaultSaveLocation(path);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Developer Section
              const DeveloperSection(),
              const SizedBox(height: 28),

              // Clear all local data
              Card(
                color: Colors.red.withOpacity(isDark ? 0.12 : 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  title: Text(
                    l10n.clearAllData,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showClearDataDialog(context, l10n),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  '${l10n.appName} v1.0.0 • 100% Offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFA2A5AD)
              : const Color(0xFF686E77),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await projectService.clearAll();
              await settingsService.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.clearDataSuccess)),
                );
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
