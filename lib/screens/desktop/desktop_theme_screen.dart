import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class DesktopThemeScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onFinishOnboarding;
  final VoidCallback? onBack;

  const DesktopThemeScreen({
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

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          onFinishOnboarding();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 36.0),
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
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDesktopThemeCard(
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
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDesktopThemeCard(
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
                    const SizedBox(height: 36),
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

  Widget _buildDesktopThemeCard(
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
        padding: const EdgeInsets.all(18),
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
            const SizedBox(height: 16),
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(Icons.grid_view_rounded, color: textColor.withOpacity(0.6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 40,
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
