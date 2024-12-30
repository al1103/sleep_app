import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep/shared/app_colors.dart';
import 'package:sleep/shared/app_fonts.dart';
import 'package:sleep/shared/application/shared_preferences_provider.dart';
import 'package:sleep/shared/globals.dart';
import 'package:sleep/shared/theme/text_styles.dart';
import 'package:sleep/shared/theme/text_theme.dart';

final appThemeProvider = StateNotifierProvider<AppThemeModeNotifier, ThemeMode>(
  (ref) {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    return AppThemeModeNotifier(sharedPreferences);
  },
);

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  AppThemeModeNotifier(this.sharedPreferences) : super(ThemeMode.light) {
    getCurrentTheme();
  }

  final SharedPreferences sharedPreferences;

  ThemeMode currentTheme = ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    sharedPreferences.setString(APP_THEME_STORAGE_KEY, state.name);
  }

  Future<void> getCurrentTheme() async {
    final theme = sharedPreferences.get(APP_THEME_STORAGE_KEY);
    final value = ThemeMode.values.byName('${theme ?? 'light'}');
    state = value;
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppFonts.montserrat,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.lightGrey,
        error: AppColors.error,
        surface: AppColors.black,
      ),
      // backgroundColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.black,
      textTheme: TextThemes.darkTextTheme,
      primaryTextTheme: TextThemes.primaryTextTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.black,
        titleTextStyle: AppTextStyles.h2,
      ),
    );
  }

  /// Light theme data of the app
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: AppFonts.montserrat,
      primaryColor: AppColors.primary,
      textTheme: TextThemes.textTheme,
      primaryTextTheme: TextThemes.primaryTextTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.lightGrey,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
