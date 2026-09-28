import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/authentication/pages/login_page.dart';
import '../../features/authentication/pages/register_page.dart';
import '../../features/authentication/pages/forgot_password_page.dart';
import '../../features/authentication/pages/reset_password_page.dart';
import '../../features/authentication/pages/account_pending_page.dart';
import '../../features/client/pages/client_dashboard_page.dart';
import '../../features/landlord/pages/landlord_dashboard_page.dart';
import '../../features/admin/pages/admin_dashboard_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/property/pages/property_details_page.dart';
import '../../features/property/pages/publish_property_page.dart';
import '../../features/property/pages/edit_property_page.dart';
import '../../features/property/pages/visit_requests_page.dart';
import '../../features/property/pages/landlord_visit_requests_page.dart';
import '../../features/search/pages/search_page.dart';
import '../../features/chat/pages/messages_page.dart';
import '../../features/chat/pages/chat_thread_page.dart';
import '../../features/chatbot/pages/chatbot_page.dart';
import '../../features/favorites/pages/favorites_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/onboarding/pages/splash_page.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/legal/pages/terms_and_license_page.dart';

/// Configuration du routeur de l'application
class AppRouter {
  /// Routeur GoRouter
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: AppConfig.isDebugMode,
    routes: _routes,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );

  /// Liste des routes
  static final List<GoRoute> _routes = [
    // Splash & Onboarding
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // Home
    GoRoute(
      path: AppConstants.routeHome,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    // Authentication
    GoRoute(
      path: AppConstants.routeLogin,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppConstants.routeRegister,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppConstants.routeForgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordPage(token: token);
      },
    ),
    GoRoute(
      path: '/compte-en-attente',
      name: 'account-pending',
      builder: (context, state) => const AccountPendingPage(),
    ),

    // Dashboards
    GoRoute(
      path: AppConstants.routeClientDashboard,
      name: 'client-dashboard',
      builder: (context, state) => const ClientDashboardPage(),
    ),
    GoRoute(
      path: AppConstants.routeLandlordDashboard,
      name: 'landlord-dashboard',
      builder: (context, state) => const LandlordDashboardPage(),
    ),
    GoRoute(
      path: AppConstants.routeAdminDashboard,
      name: 'admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),

    // User
    GoRoute(
      path: AppConstants.routeProfile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppConstants.routeSettings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) {
        final requireAcceptance = state.uri.queryParameters['requireAcceptance'] == 'true';
        return TermsAndLicensePage(requireAcceptance: requireAcceptance);
      },
    ),

    // Property
    GoRoute(
      path: '/properties/publish',
      name: 'publish-property',
      builder: (context, state) => const PublishPropertyPage(),
    ),
    GoRoute(
      path: '/properties/:id/edit',
      name: 'edit-property',
      builder: (context, state) {
        final propertyId = state.pathParameters['id'];
        return EditPropertyPage(propertyId: propertyId ?? '');
      },
    ),
    GoRoute(
      path: AppConstants.routePropertyDetails,
      name: 'property-details',
      builder: (context, state) {
        final propertyId = state.pathParameters['id'];
        return PropertyDetailsPage(propertyId: propertyId ?? '');
      },
    ),

    // Features
    GoRoute(
      path: AppConstants.routeSearch,
      name: 'search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: AppConstants.routeChat,
      name: 'chat',
      builder: (context, state) => const MessagesPage(),
    ),
    GoRoute(
      path: '/chat/:id',
      name: 'chat-thread',
      builder: (context, state) {
        final conversationId = state.pathParameters['id'] ?? '';
        return ChatThreadPage(conversationId: conversationId);
      },
    ),
    GoRoute(
      path: AppConstants.routeChatbot,
      name: 'chatbot',
      builder: (context, state) => const ChatbotPage(),
    ),
    GoRoute(
      path: AppConstants.routeFavorites,
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: AppConstants.routeNotifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/visits/my',
      name: 'my-visits',
      builder: (context, state) => const VisitRequestsPage(),
    ),
    GoRoute(
      path: '/visits/landlord',
      name: 'landlord-visits',
      builder: (context, state) => const LandlordVisitRequestsPage(),
    ),
  ];
}

/// Page d'erreur
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Une erreur est survenue',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Erreur inconnue',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
