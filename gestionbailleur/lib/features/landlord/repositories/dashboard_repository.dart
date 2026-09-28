import 'package:gestionbailleur/core/network/network_exceptions.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_summary_model.dart';
import '../../home/models/property_model.dart';
import '../../domain/models/visite.dart';
import '../../chat/models/conversation_model.dart';

/// Repository pour gérer l'agrégation et la conversion des données du dashboard bailleur
class DashboardRepository {
  final DashboardRemoteDataSource _dataSource;

  DashboardRepository({DashboardRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? DashboardRemoteDataSource();

  /// Récupère toutes les données nécessaires au dashboard bailleur de manière concurrente
  Future<DashboardSummaryModel> getDashboardSummary(String landlordId) async {
    try {
      // Exécute tous les appels API en parallèle pour optimiser les performances
      final results = await Future.wait([
        _dataSource.getLandlordProperties(landlordId),
        _dataSource.getLandlordVisits(),
        _dataSource.getConversations(),
        _dataSource.getUnreadNotificationsCount(),
      ]);

      final propertiesRaw = results[0] as List<dynamic>;
      final visitsRaw = results[1] as List<dynamic>;
      final conversationsRaw = results[2] as List<dynamic>;
      final unreadNotifications = results[3] as int;

      // Désérialisation propre en modèles réels
      final properties = propertiesRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => PropertyModel.fromJson(json))
          .toList();

      final visits = visitsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => Visite.fromMap(json))
          .toList();

      final conversations = conversationsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => ConversationModel.fromJson(json))
          .toList();

      return DashboardSummaryModel(
        properties: properties,
        visits: visits,
        conversations: conversations,
        unreadNotificationsCount: unreadNotifications,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gère proprement les erreurs de réseau en retournant des NetworkExceptions typées
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
