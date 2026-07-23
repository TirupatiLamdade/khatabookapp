import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ThemeModeOption { light, dark, amoled, eyeSoothingDark }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModeOption>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  // 👁️ Default Option: Eye-Soothing Dark for maximum comfort
  ThemeNotifier() : super(ThemeModeOption.eyeSoothingDark);

  void setTheme(ThemeModeOption option) => state = option;

  ThemeData getThemeData() {
    switch (state) {
      case ThemeModeOption.light:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0066CC),
            brightness: Brightness.light,
          ),
        );

      case ThemeModeOption.dark:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0066CC),
            brightness: Brightness.dark,
          ),
        );

      case ThemeModeOption.amoled:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0066CC),
            brightness: Brightness.dark,
            surface: const Color(0xFF121212),
          ),
        );

      // 🌿 EYE-SOOTHING DARK SLATE & EMERALD THEME (For Whole App Consistency)
      case ThemeModeOption.eyeSoothingDark:
        const primaryAccent = Color(0xFF38BDF8); // Soft Cyber Ice Blue
        const greenSuccess = Color(0xFF10B981); // Soothing Emerald Green
        const darkBackground = Color(0xFF0F172A); // Deep Eye-Care Slate
        const cardSurface = Color(0xFF1E293B); // Muted Dark Slate Surface

        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: darkBackground,
          
          // 🎨 Unified Color Scheme
          colorScheme: const ColorScheme.dark(
            primary: primaryAccent,
            secondary: greenSuccess,
            surface: cardSurface,
            error: Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSurface: Color(0xFFE2E8F0),
          ),

          // 🎴 Card Theme for seamless glass/box styling
          cardTheme: CardThemeData(
            color: cardSurface.withOpacity(0.85),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),

          // 📝 Input Field Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF080B10).withOpacity(0.6),
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            prefixIconColor: const Color(0xFF94A3B8),
            suffixIconColor: const Color(0xFF94A3B8),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryAccent, width: 1.5),
            ),
          ),

          // 🔘 Elevated Button Theme (High-Contrast Green)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: greenSuccess,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: greenSuccess.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // 💬 Text Theme with Eye-Soothing Slate Colors
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Color(0xFFE2E8F0)),
            bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
          ),
        );
    }
  }
}