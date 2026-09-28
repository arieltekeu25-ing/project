import 'package:flutter/material.dart';

/// Constantes globales de l'application
class AppConstants {
  // ============================================
  // Dimensions
  // ============================================
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // ============================================
  // Ombres
  // ============================================
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // ============================================
  // Animations
  // ============================================
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveBounce = Curves.easeOutBack;

  // ============================================
  // Breakpoints Responsive
  // ============================================
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
  static const double breakpointLargeDesktop = 1600;

  // ============================================
  // Pagination
  // ============================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============================================
  // Validation
  // ============================================
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxUsernameLength = 50;
  static const int maxBioLength = 500;

  // ============================================
  // Storage
  // ============================================
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // ============================================
  // Routes
  // ============================================
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeClientDashboard = '/client/dashboard';
  static const String routeLandlordDashboard = '/landlord/dashboard';
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
  static const String routePropertyDetails = '/property/:id';
  static const String routeSearch = '/search';
  static const String routeChat = '/chat';
  static const String routeChatbot = '/chatbot';
  static const String routeFavorites = '/favorites';
  static const String routeNotifications = '/notifications';
  static const String routePublish = '/properties/publish';
  static const String routeEditProperty = '/property/:id/edit';
}
