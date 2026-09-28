import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Bibliothèque d'animations du Design System
class DSAnimations {
  // ============================================
  // Durées
  // ============================================
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);

  // ============================================
  // Curves
  // ============================================
  static const Curve ease = Curves.ease;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // ============================================
  // Animations Fade
  // ============================================
  static Widget fadeIn({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget fadeOut({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // ============================================
  // Animations Slide
  // ============================================
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
    Offset begin = const Offset(0, 0.3),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideInFromTop({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return slideInFromBottom(
      child: child,
      begin: const Offset(0, -0.3),
      duration: duration,
      curve: curve,
    );
  }

  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideInFromRight({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // ============================================
  // Animations Scale
  // ============================================
  static Widget scaleIn({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurveBounce,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget scaleOut({
    required Widget child,
    Duration duration = AppConstants.animationDurationMedium,
    Curve curve = AppConstants.animationCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.8),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // ============================================
  // Animation combinée (Fade + Slide)
  // ============================================
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = AppConstants.animationDurationLong,
    Curve curve = AppConstants.animationCurve,
    Offset begin = const Offset(0, 0.3),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, opacity, child) {
        return TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(begin: begin, end: Offset.zero),
          duration: duration,
          curve: curve,
          builder: (context, offset, child) {
            return Transform.translate(
              offset: offset,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
