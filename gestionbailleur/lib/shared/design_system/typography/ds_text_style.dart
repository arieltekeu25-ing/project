import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Système de typographie du Design System
class DSTextStyle {
  // ============================================
  // Display - Pour les titres très importants
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22,
  );

  // ============================================
  // Headline - Pour les titres de sections
  // ============================================
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ============================================
  // Title - Pour les titres de cartes et widgets
  // ============================================
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.50,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  // ============================================
  // Body - Pour le texte de contenu
  // ============================================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  // ============================================
  // Label - Pour les labels et boutons
  // ============================================
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  // ============================================
  // Couleurs du texte
  // ============================================
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static const TextStyle primary = TextStyle(color: AppColors.primary);
  static const TextStyle secondary = TextStyle(color: AppColors.secondary);
  static const TextStyle error = TextStyle(color: AppColors.error);
  static const TextStyle success = TextStyle(color: AppColors.success);
  static const TextStyle warning = TextStyle(color: AppColors.warning);
}
