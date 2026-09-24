// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Laqtat';

  @override
  String get appDescription =>
      'Extract key frames from any video and assemble them into a stunning grid image ready to export.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get selectLanguagePrompt =>
      'Select your preferred application language';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get selectThemePrompt => 'Select your preferred visual style';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get projects => 'Projects';

  @override
  String get settings => 'Settings';

  @override
  String get newProject => 'New Project';

  @override
  String get importVideo => 'Import Video';

  @override
  String get importVideoPrompt =>
      'Select a local video or drag and drop it here';

  @override
  String get supportedFormats =>
      'Supported: MP4, MOV, MKV, WebM, AVI, FLV, WMV, TS, RM...';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get export => 'Export';

  @override
  String get exportImage => 'Export Image';

  @override
  String get exportPng => 'Export PNG';

  @override
  String get exportJpg => 'Export JPG';

  @override
  String get exportQuality => 'Grid Quality';

  @override
  String get standardQuality => 'Standard (Faster)';

  @override
  String get highQuality => 'High Resolution';

  @override
  String get frameCount => 'Frame Count';

  @override
  String get defaultFrameCount => 'Default Frame Count';

  @override
  String get defaultExportFormat => 'Default Export Format';

  @override
  String get defaultSaveLocation => 'Default Save Location';

  @override
  String get systemDefault => 'System Default';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get clearAllData => 'Clear All Local Data';

  @override
  String get clearDataConfirmation =>
      'Are you sure you want to delete all saved projects and reset settings?';

  @override
  String get clearDataSuccess => 'All local data has been cleared.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get deleteProjectConfirmation =>
      'Are you sure you want to delete this project?';

  @override
  String get noProjectsTitle => 'No Projects Yet';

  @override
  String get noProjectsSubtitle =>
      'Import a video to generate your first frame grid';

  @override
  String processingVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Extracting $count frames from video...',
      one: 'Extracting 1 frame from video...',
    );
    return '$_temp0';
  }

  @override
  String get generatingGrid => 'Assembling frame grid...';

  @override
  String get exportSuccess => 'Image saved to Gallery successfully';

  @override
  String get exportFailed => 'Failed to export image.';

  @override
  String get unsupportedVideoFormat =>
      'Unsupported video format. Please select a supported video file.';

  @override
  String get ffmpegNotFound =>
      'ffmpeg binary not found on system. Please install ffmpeg.';

  @override
  String get webStorageNotice =>
      'Note: On Web, projects are stored locally in this browser.';

  @override
  String get videoDuration => 'Duration';

  @override
  String get dateCreated => 'Created';

  @override
  String get projectDetails => 'Project Details';

  @override
  String framesExtracted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count frames extracted',
      one: '1 frame extracted',
    );
    return '$_temp0';
  }

  @override
  String get aboutApp => 'About Laqtat';

  @override
  String get version => 'Version';

  @override
  String get offlineNote =>
      '100% Offline & Private: No video or data ever leaves your device.';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get copy => 'Copy';

  @override
  String get errorLoadingVideo =>
      'This video could not be read. Please try another video.';

  @override
  String get developer => 'Developer';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';
}
