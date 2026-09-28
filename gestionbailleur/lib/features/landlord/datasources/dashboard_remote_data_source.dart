import 'package:gestionbailleur/core/services/api_service.dart';
import 'package:gestionbailleur/core/network/api_endpoints.dart';

/// Source de données distante pour le Dashboard du bailleur
class DashboardRemoteDataSource {
  final ApiService _apiService;

  DashboardRemoteDataSource({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Récupère la liste brute des logements appartenant au bailleur
  Future<List<dynamic>> getLandlordProperties(String landlordId) async {
    final response = await _apiService.get(
      ApiEndpoints.landlordProperties(landlordId),
      requireAuth: true,
    );

    if (response is List) {
      return response;
    } else if (response is Map && response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    return [];
  }

  /// Récupère la liste brute des demandes de visite reçues par le bailleur
  Future<List<dynamic>> getLandlordVisits() async {
    final response = await _apiService.get(
      ApiEndpoints.landlordVisits,
      requireAuth: true,
    );

    if (response is List) {
      return response;
    } else if (response is Map && response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    return [];
  }

  /// Récupère la liste brute des conversations du bailleur
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _apiService.get(
        '/api/v1/messages/conversations/',
        requireAuth: true,
      );

      if (response is List) {
        return response;
      } else if (response is Map && response.containsKey('results')) {
        return response['results'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      // Si l'endpoint messages n'est pas disponible, retourner une liste vide sans bloquer le dashboard
      return [];
    }
  }

  /// Récupère le nombre de notifications non lues du bailleur
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _apiService.get(
        '/api/v1/notifications/unread-count/',
        requireAuth: true,
      );

      if (response is Map && response.containsKey('unread_count')) {
        return (response['unread_count'] ?? 0) as int;
      }
      return 0;
    } catch (_) {
      // Si l'endpoint notifications n'est pas disponible, retourner 0 sans bloquer le dashboard
      return 0;
    }
  }
}
