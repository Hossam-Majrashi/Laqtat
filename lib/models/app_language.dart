class AppLanguage {
  final String id;
  final String name;
  final String nativeName;
  final bool isRTL;

  const AppLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.isRTL,
  });

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      id: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      isRTL: true,
    ),
    AppLanguage(
      id: 'en',
      name: 'English',
      nativeName: 'English',
      isRTL: false,
    ),
  ];

  static AppLanguage fromId(String id) {
    return supportedLanguages.firstWhere(
      (lang) => lang.id == id,
      orElse: () => supportedLanguages.first,
    );
  }
}
