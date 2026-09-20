import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/language_screen.dart';
import 'screens/theme_screen.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/project_service.dart';
import 'services/video_grid_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final projectService = ProjectService();
  await projectService.init();

  runApp(LaqtatApp(
    settingsService: settingsService,
    projectService: projectService,
  ));
}

class LaqtatApp extends StatefulWidget {
  final SettingsService settingsService;
  final ProjectService projectService;

  const LaqtatApp({
    super.key,
    required this.settingsService,
    required this.projectService,
  });

  @override
  State<LaqtatApp> createState() => _LaqtatAppState();
}

class _LaqtatAppState extends State<LaqtatApp> {
  final VideoGridService _videoGridService = VideoGridService();
  int _onboardingStep = 0; // 0: Splash/About, 1: Language, 2: Theme

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsService,
      builder: (context, _) {
        final locale = Locale(widget.settingsService.languageCode);

        return MaterialApp(
          title: 'لقطات (Laqtat)',
          debugShowCheckedModeBanner: false,
          themeMode: widget.settingsService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget.settingsService.isOnboardingComplete
              ? HomeScreen(
                  projectService: widget.projectService,
                  videoGridService: _videoGridService,
                  settingsService: widget.settingsService,
                )
              : _buildOnboardingFlow(),
        );
      },
    );
  }

  Widget _buildOnboardingFlow() {
    switch (_onboardingStep) {
      case 0:
        return SplashScreen(
          onNext: () => setState(() => _onboardingStep = 1),
        );
      case 1:
        return LanguageScreen(
          currentLanguageCode: widget.settingsService.languageCode,
          onLanguageSelected: (code) => widget.settingsService.setLanguageCode(code),
          onNext: () => setState(() => _onboardingStep = 2),
          onBack: () => setState(() => _onboardingStep = 0),
        );
      case 2:
      default:
        return ThemeScreen(
          currentThemeMode: widget.settingsService.themeMode,
          onThemeChanged: (mode) => widget.settingsService.setThemeMode(mode),
          onFinishOnboarding: () async {
            await widget.settingsService.setOnboardingComplete(true);
          },
          onBack: () => setState(() => _onboardingStep = 1),
        );
    }
  }
}
