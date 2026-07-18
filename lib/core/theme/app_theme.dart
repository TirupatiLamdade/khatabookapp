import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeOption { light, dark, amoled }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModeOption>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeNotifier() : super(ThemeModeOption.light);

  void setTheme(ThemeModeOption option) => state = option;

  ThemeData getThemeData() {
    switch (state) {
      case ThemeModeOption.light:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        );
      case ThemeModeOption.dark:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        );
      case ThemeModeOption.amoled:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
            background: Colors.black,
            surface: Colors.grey[900]!,
          ),
        );
    }
  }
}