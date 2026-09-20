import 'package:flutter/material.dart';

class AppTheme {
  // Exact mandated colors from §3
  static const Color darkBackground = Color(0xFF212327);
  static const Color darkSurface = Color(0xFF232627);
  static const Color darkCard = Color(0xFF2B2E33);
  static const Color darkBorder = Color(0xFF383C42);

  static const Color lightBackground = Color(0xFFEFEEF1);
  static const Color lightSurface = Color(0xFFFEFEFE);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0DFE5);

  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color primaryAccentLight = Color(0xFF4F46E5);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryAccent,
    canvasColor: darkBackground,
    cardColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: primaryAccent,
      secondary: Color(0xFF818CF8),
      surface: darkSurface,
      surfaceContainerHighest: darkCard,
      onPrimary: Colors.white,
      onSurface: Color(0xFFF1F2F4),
      outline: darkBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Color(0xFFF1F2F4),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        side: const BorderSide(color: darkBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFE2E4E9),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryAccent,
      unselectedItemColor: Color(0xFF8E929C),
      elevation: 0,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkSurface,
      selectedIconTheme: IconThemeData(color: primaryAccent),
      unselectedIconTheme: IconThemeData(color: Color(0xFF8E929C)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: primaryAccentLight,
    canvasColor: lightBackground,
    cardColor: lightSurface,
    colorScheme: const ColorScheme.light(
      primary: primaryAccentLight,
      secondary: Color(0xFF4338CA),
      surface: lightSurface,
      surfaceContainerHighest: Color(0xFFF7F6F9),
      onPrimary: Colors.white,
      onSurface: Color(0xFF1F242D),
      outline: lightBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: Color(0xFF1F242D),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightSurface,
        foregroundColor: Color(0xFF1F242D),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: lightSurface,
        foregroundColor: Color(0xFF1F242D),
        side: const BorderSide(color: lightBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF333842),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryAccentLight,
      unselectedItemColor: Color(0xFF6B7280),
      elevation: 4,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: lightSurface,
      selectedIconTheme: IconThemeData(color: primaryAccentLight),
      unselectedIconTheme: IconThemeData(color: Color(0xFF6B7280)),
    ),
  );
}
