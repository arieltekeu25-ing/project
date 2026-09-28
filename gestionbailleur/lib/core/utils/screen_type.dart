import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Type d'écran pour le responsive design
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Extension sur BuildContext pour obtenir le type d'écran
extension ScreenTypeExtension on BuildContext {
  /// Obtenir le type d'écran actuel
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    if (width < AppConstants.breakpointMobile) {
      return ScreenType.mobile;
    } else if (width < AppConstants.breakpointTablet) {
      return ScreenType.tablet;
    } else if (width < AppConstants.breakpointDesktop) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Vérifier si c'est un mobile
  bool get isMobile => screenType == ScreenType.mobile;

  /// Vérifier si c'est une tablette
  bool get isTablet => screenType == ScreenType.tablet;

  /// Vérifier si c'est un desktop
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Vérifier si c'est un grand écran
  bool get isLargeDesktop => screenType == ScreenType.largeDesktop;

  /// Vérifier si c'est un écran mobile ou tablette
  bool get isMobileOrTablet => isMobile || isTablet;

  /// Vérifier si c'est un écran desktop ou grand écran
  bool get isDesktopOrLarge => isDesktop || isLargeDesktop;
}
