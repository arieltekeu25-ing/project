import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Schéma de couleurs de l'application
class AppColorScheme {
  /// Schéma de couleurs clair
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.warning,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: Color(0xFFF1F5F9),
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: Color(0xFFE2E8F0),
    shadow: AppColors.shadow,
    scrim: AppColors.shadowDark,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textPrimaryDark,
    inversePrimary: AppColors.primaryLight,
  );

  /// Schéma de couleurs sombre
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1E3A8A),
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF064E3B),
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.warning,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: Color(0xFF1E293B),
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: Color(0xFF334155),
    shadow: AppColors.shadow,
    scrim: AppColors.shadowDark,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primary,
  );
}
