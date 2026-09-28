import '../../../core/services/api_service.dart';
import '../models/notification_model.dart';

/// Repository pour la gestion des notifications
class NotificationRepository {
  final ApiService _apiService = ApiService.instance;

  /// Récupérer les notifications de l'utilisateur
  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    try {
      final queryParams = <String, String>{};
      if (unreadOnly) {
        queryParams['unread'] = 'true';
      }

      final response = await _apiService.get(
        '/api/v1/notifications/',
        queryParams: queryParams,
        requireAuth: true,
      );

      List<NotificationModel> notifications;
      if (response is List) {
        notifications = response.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        notifications = results.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        notifications = [];
      }

      return notifications;
    } catch (e) {
      // Si l'endpoint n'existe pas encore, retourner une liste vide
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/notifications/$notificationId/read/',
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post(
        '/api/v1/notifications/mark-all-read/',
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete(
        '/api/v1/notifications/$notificationId/',
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/api/v1/notifications/unread-count/',
        requireAuth: true,
      );

      if (response is Map && response.containsKey('count')) {
        return (response['count'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
