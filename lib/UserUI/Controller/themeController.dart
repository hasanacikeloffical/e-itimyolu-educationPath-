import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'theme_mode';
  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();

    final v = sp.getInt(_key) ?? 0;
    themeNotifier.value = v == 0
        ? ThemeMode.light
        : (v == 1 ? ThemeMode.dark : ThemeMode.system);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    final sp = await SharedPreferences.getInstance();
    final v = mode == ThemeMode.light ? 0 : (mode == ThemeMode.dark ? 1 : 2);
    await sp.setInt(_key, v);
  }

  static ThemeData lightTheme() {
    final seed = const Color(0xFF0D47A1);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(background: Colors.white, onBackground: Colors.black87);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        centerTitle: true,
      ),
      cardColor: colorScheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: Typography.material2018().black.apply(
        bodyColor: colorScheme.onBackground,
      ),
    );
  }

  static ThemeData darkTheme() {
    final seed = const Color(0xFF0D47A1);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          background: const Color(0xFF061328),
          onBackground: Colors.white,
          surface: const Color(0xFF07213A),
          onSurface: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        centerTitle: true,
      ),
      cardColor: colorScheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: Typography.material2018().white.apply(
        bodyColor: colorScheme.onBackground,
      ),
    );
  }
}
