/// Configuration globale de l'application
class AppConfig {
  // Environnement
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  // Développement : http://localhost:8000 (par défaut)
  // Production : utiliser --dart-define=API_BASE_URL=https://gestionbailleur-backend-production.up.railway.app
  // Android physique avec backend local : utiliser --dart-define=API_BASE_URL=http://192.168.x.x:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://project-production-0e57.up.railway.app', // Backend de production sur Railway
  );

  static const int apiTimeout = 60000; // 60 secondes (60000ms) pour les requêtes API et l'IA

  // Feature Flags
  static const bool enableFirebase = false;
  static const bool enableAnalytics = false;
  static const bool enablePushNotifications = false;

  // App Info
  static const String appName = 'GestionBailleur';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Debug Mode
  static bool get isDebugMode => environment != 'production';
}
