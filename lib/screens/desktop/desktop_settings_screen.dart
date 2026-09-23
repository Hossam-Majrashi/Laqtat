import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_language.dart';
import '../../services/settings_service.dart';
import '../../services/project_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/developer_section.dart';

class DesktopSettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final ProjectService projectService;

  const DesktopSettingsScreen({
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListenableBuilder(
            listenable: settingsService,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                children: [
                  // Language Switcher
                  _buildSectionHeader(context, l10n.language),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: AppLanguage.supportedLanguages.map((lang) {
                          final isSelected = lang.id == settingsService.languageCode;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChoiceChip(
                                label: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      '${lang.nativeName} (${lang.name})',
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryAccent.withOpacity(0.2),
                                onSelected: (selected) {
                                  if (selected) settingsService.setLanguageCode(lang.id);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme Switcher (exact colors)
                  _buildSectionHeader(context, l10n.theme),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: settingsService.themeMode == ThemeMode.dark
                                      ? AppTheme.primaryAccent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              tileColor: isDark ? AppTheme.darkCard : const Color(0xFFF3F2F6),
                              leading: const Icon(Icons.dark_mode_rounded),
                              title: Text(l10n.darkMode),
                              subtitle: const Text('#212327 / #232627'),
                              trailing: settingsService.themeMode == ThemeMode.dark
                                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent)
                                  : null,
                              onTap: () => settingsService.setThemeMode(ThemeMode.dark),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: settingsService.themeMode == ThemeMode.light
                                      ? AppTheme.primaryAccent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              tileColor: isDark ? AppTheme.darkCard : const Color(0xFFF3F2F6),
                              leading: const Icon(Icons.light_mode_rounded),
                              title: Text(l10n.lightMode),
                              subtitle: const Text('#efeef1 / #fefefe'),
                              trailing: settingsService.themeMode == ThemeMode.light
                                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent)
                                  : null,
                              onTap: () => settingsService.setThemeMode(ThemeMode.light),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                                  ButtonSegment(value: 'standard', label: Text(l10n.standardQuality)),
                                  ButtonSegment(value: 'high', label: Text(l10n.highQuality)),
                                ],
                                selected: {settingsService.gridQuality},
                                onSelectionChanged: (set) {
                                  settingsService.setGridQuality(set.first);
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
                                      l10n.defaultSaveLocation,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      settingsService.defaultSaveLocation ?? l10n.systemDefault,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.folder_open_rounded, size: 18),
                                label: Text(l10n.selectFolder),
                                onPressed: () async {
                                  final path = await FilePicker.getDirectoryPath();
                                  if (path != null) {
                                    settingsService.setDefaultSaveLocation(path);
                                  }
                                },
                              ),
                              if (settingsService.defaultSaveLocation != null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => settingsService.setDefaultSaveLocation(null),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

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
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _showClearDataDialog(context, l10n),
                        child: Text(l10n.clearAllData),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

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
