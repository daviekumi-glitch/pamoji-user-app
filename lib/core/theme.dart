// PAMOJI design language: warm African marketplace — deep charcoal,
// chibadwa green, soft cards, generous spacing.
import 'package:flutter/material.dart';

class PamojiColors {
  static const bg = Color(0xFF12141A);
  static const surface = Color(0xFF1B1E26);
  static const surface2 = Color(0xFF242833);
  static const text = Color(0xFFF2F4F8);
  static const dim = Color(0xFF98A1B3);
  static const green = Color(0xFF0E9F6E);
  static const gold = Color(0xFFE8B931);
  static const danger = Color(0xFFEF4444);
}

ThemeData pamojiTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: PamojiColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: PamojiColors.green,
      secondary: PamojiColors.gold,
      surface: PamojiColors.surface,
      error: PamojiColors.danger,
    ),
    cardTheme: const CardThemeData(
      color: PamojiColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PamojiColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: PamojiColors.dim),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PamojiColors.bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          color: PamojiColors.text, fontSize: 22, fontWeight: FontWeight.w800),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: PamojiColors.surface2,
      selectedColor: PamojiColors.green,
      labelStyle: const TextStyle(color: PamojiColors.text, fontSize: 12.5),
      secondaryLabelStyle: const TextStyle(color: PamojiColors.text, fontSize: 12.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PamojiColors.surface,
      indicatorColor: PamojiColors.green.withOpacity(0.25),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
    ),
  );
}
