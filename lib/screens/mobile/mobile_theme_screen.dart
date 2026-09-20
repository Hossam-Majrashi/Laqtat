import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class MobileThemeScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onFinishOnboarding;
  final VoidCallback? onBack;

  const MobileThemeScreen({
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectThemePrompt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? const Color(0xFFA2A5AD) : const Color(0xFF686E77),
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildThemeCard(
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
                    _buildThemeCard(
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
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onFinishOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.getStarted,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? AppTheme.primaryAccent : textColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent, size: 22)
                else
                  Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.5), size: 22),
              ],
            ),
            const SizedBox(height: 14),
            // Mock UI mini container demonstrating exact background (#212327 or #efeef1) and surface (#232627 or #fefefe)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(Icons.image_outlined, color: textColor.withOpacity(0.6), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.25),
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
