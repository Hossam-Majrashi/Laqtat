import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class WebThemeScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onFinishOnboarding;
  final VoidCallback? onBack;

  const WebThemeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onFinishOnboarding,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.of(context).size.width < 620;

    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              )
            : null,
        title: Text(l10n.chooseTheme),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
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
                      l10n.chooseTheme,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.selectThemePrompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? const Color(0xFFA2A5AD) : const Color(0xFF686E77),
                          ),
                    ),
                    const SizedBox(height: 24),
                    if (isCompact)
                      Column(
                        children: [
                          _buildWebThemeCard(
                            context,
                            mode: ThemeMode.dark,
                            title: l10n.darkMode,
                            bgColor: AppTheme.darkBackground,
                            surfaceColor: AppTheme.darkSurface,
                            borderColor: AppTheme.darkBorder,
                            textColor: Colors.white,
                            icon: Icons.dark_mode_rounded,
                            isSelected: currentThemeMode == ThemeMode.dark,
                          ),
                          const SizedBox(height: 16),
                          _buildWebThemeCard(
                            context,
                            mode: ThemeMode.light,
                            title: l10n.lightMode,
                            bgColor: AppTheme.lightBackground,
                            surfaceColor: AppTheme.lightSurface,
                            borderColor: AppTheme.lightBorder,
                            textColor: const Color(0xFF1F242D),
                            icon: Icons.light_mode_rounded,
                            isSelected: currentThemeMode == ThemeMode.light,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildWebThemeCard(
                              context,
                              mode: ThemeMode.dark,
                              title: l10n.darkMode,
                              bgColor: AppTheme.darkBackground,
                              surfaceColor: AppTheme.darkSurface,
                              borderColor: AppTheme.darkBorder,
                              textColor: Colors.white,
                              icon: Icons.dark_mode_rounded,
                              isSelected: currentThemeMode == ThemeMode.dark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildWebThemeCard(
                              context,
                              mode: ThemeMode.light,
                              title: l10n.lightMode,
                              bgColor: AppTheme.lightBackground,
                              surfaceColor: AppTheme.lightSurface,
                              borderColor: AppTheme.lightBorder,
                              textColor: const Color(0xFF1F242D),
                              icon: Icons.light_mode_rounded,
                              isSelected: currentThemeMode == ThemeMode.light,
                            ),
                          ),
                        ],
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
                          onPressed: onFinishOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          ),
                          child: Row(
                            children: [
                              Text(l10n.getStarted),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_rounded, size: 18),
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

  Widget _buildWebThemeCard(
    BuildContext context, {
    required ThemeMode mode,
    required String title,
    required Color bgColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onThemeChanged(mode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAccent : borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? AppTheme.primaryAccent : textColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent, size: 20)
                else
                  Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.5), size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(Icons.grid_view_rounded, color: textColor.withOpacity(0.6), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 35,
                          height: 6,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
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
