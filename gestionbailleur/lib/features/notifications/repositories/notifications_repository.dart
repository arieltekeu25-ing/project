import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/notification_model.dart';

/// Repository pour la gestion des notifications réelles de l'utilisateur
class NotificationsRepository {
  final ApiService _apiService;

  NotificationsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Récupérer les notifications de l'utilisateur connecté
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get(
        '/api/v1/notifications/',
        requireAuth: true,
      );

      List<NotificationModel> notifications = [];
      if (response is List) {
        notifications = response.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        notifications = results.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return notifications;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/api/v1/notifications/unread-count/',
        requireAuth: true,
      );

      if (response is Map && response.containsKey('unread_count')) {
        return (response['unread_count'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      await _apiService.post(
        '/api/v1/notifications/mark-read/',
        requireAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Marquer une notification individuelle comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiService.patch(
        '/api/v1/notifications/$notificationId/',
        body: {'is_read': true},
        requireAuth: true,
      );
      return true;
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
      // Vérifier si la réponse indique un succès (statut 204 ou 200)
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la notification: $e');
      // Essayer avec POST si DELETE échoue
      try {
        await _apiService.post(
          '/api/v1/notifications/$notificationId/delete/',
          requireAuth: true,
        );
        return true;
      } catch (e2) {
        debugPrint('Erreur avec POST /delete/: $e2');
        // Essayer avec PATCH pour marquer comme supprimé
        try {
          await _apiService.patch(
            '/api/v1/notifications/$notificationId/',
            body: {'deleted': true},
            requireAuth: true,
          );
          return true;
        } catch (e3) {
          debugPrint('Erreur avec PATCH deleted: $e3');
          return false;
        }
      }
    }
  }

  /// Gérer les erreurs
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
