import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_language.dart';
import '../../services/settings_service.dart';
import '../../services/project_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/developer_section.dart';

class WebSettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final ProjectService projectService;

  const WebSettingsScreen({
    super.key,
    required this.settingsService,
    required this.projectService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: settingsService,
            builder: (context, _) {
              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16.0 : 28.0,
                  vertical: 24.0,
                ),
                children: [
                  // Web Storage Info Notice
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : const Color(0xFFEFEFF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.primaryAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.webStorageNotice,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Language Switcher
                  _buildSectionHeader(context, l10n.language),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: AppLanguage.supportedLanguages.map((lang) {
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
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  // Export Defaults
                  _buildSectionHeader(context, l10n.export),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.defaultExportFormat,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'png', label: Text('PNG')),
                                  ButtonSegment(value: 'jpg', label: Text('JPG')),
                                ],
                                selected: {settingsService.defaultExportFormat},
                                onSelectionChanged: (set) {
                                  settingsService.setDefaultExportFormat(set.first);
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.exportQuality,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      settingsService.gridQuality == 'high'
                                          ? l10n.highQuality
                                          : l10n.standardQuality,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment(value: 'standard', label: Text(l10n.standardQuality.split(' ').first)),
                                  ButtonSegment(value: 'high', label: Text(l10n.highQuality.split(' ').first)),
                                ],
                                selected: {settingsService.gridQuality},
                                onSelectionChanged: (set) {
                                  settingsService.setGridQuality(set.first);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Clear all data
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
                  const SizedBox(height: 24),

                  // Developer Section
                  const DeveloperSection(),
                ],
              );
            },
          ),
        ),
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
