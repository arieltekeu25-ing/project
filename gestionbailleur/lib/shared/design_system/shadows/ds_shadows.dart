import 'package:flutter/material.dart';

/// Système d'ombres du Design System

/// Système d'ombres du Design System
class DSShadows {
  // ============================================
  // Ombres légères
  // ============================================
  static const List<BoxShadow> xxs = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // ============================================
  // Ombres moyennes
  // ============================================
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // ============================================
  // Ombres importantes
  // ============================================
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ============================================
  // Ombres colorées (pour les éléments interactifs)
  // ============================================
  static List<BoxShadow> primary(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> secondary(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================
  // Ombres internes
  // ============================================
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
