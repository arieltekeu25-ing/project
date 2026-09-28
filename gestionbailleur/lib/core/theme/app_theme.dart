import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';
import 'app_color_scheme.dart';

/// Thème global de l'application
class AppTheme {
  /// Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.lightColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      textTheme: AppTextTheme.lightTextTheme,
      appBarTheme: _buildAppBarTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark: false),
      textButtonTheme: _buildTextButtonTheme(isDark: false),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: false),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark: false),
    );
  }

  /// Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.darkColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      textTheme: AppTextTheme.darkTextTheme,
      appBarTheme: _buildAppBarTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark: true),
      textButtonTheme: _buildTextButtonTheme(isDark: true),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: true),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark: true),
    );
  }

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme({required bool isDark}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        side: BorderSide(color: isDark ? AppColors.primaryLight : AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme({required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primary,
      unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
}
