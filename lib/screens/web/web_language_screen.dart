import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_language.dart';
import '../../theme/app_theme.dart';

class WebLanguageScreen extends StatelessWidget {
  final String currentLanguageCode;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const WebLanguageScreen({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              )
            : null,
        title: Text(l10n.chooseLanguage),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 20.0 : 36.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chooseLanguage,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.selectLanguagePrompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? const Color(0xFFA2A5AD) : const Color(0xFF686E77),
                          ),
                    ),
                    const SizedBox(height: 24),
                    if (isCompact)
                      Column(
                        children: AppLanguage.supportedLanguages.map((lang) {
                          final isSelected = lang.id == currentLanguageCode;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildLanguageTile(context, lang, isSelected, isDark),
                          );
                        }).toList(),
                      )
                    else
                      Row(
                        children: AppLanguage.supportedLanguages.map((lang) {
                          final isSelected = lang.id == currentLanguageCode;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildLanguageTile(context, lang, isSelected, isDark),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onBack != null)
                          OutlinedButton(
                            onPressed: onBack,
                            child: Text(l10n.back),
                          ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          ),
                          child: Row(
                            children: [
                              Text(l10n.next),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    AppLanguage lang,
    bool isSelected,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => onLanguageSelected(lang.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : const Color(0xFFF7F6F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryAccent
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.language_rounded,
              size: 28,
              color: isSelected ? AppTheme.primaryAccent : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              lang.nativeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.name,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFA2A5AD) : const Color(0xFF686E77),
              ),
            ),
            const SizedBox(height: 8),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryAccent,
                size: 18,
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
