import 'package:gestionbailleur/features/home/models/property_model.dart';
import 'package:gestionbailleur/features/domain/models/visite.dart';
import 'package:gestionbailleur/features/chat/models/conversation_model.dart';

/// Modèle contenant les données agrégées réelles du tableau de bord
class DashboardSummaryModel {
  final List<PropertyModel> properties;
  final List<Visite> visits;
  final List<ConversationModel> conversations;
  final int unreadNotificationsCount;

  DashboardSummaryModel({
    required this.properties,
    required this.visits,
    required this.conversations,
    required this.unreadNotificationsCount,
  });

  /// Permet d'obtenir le nombre total de logements
  int get totalPropertiesCount => properties.length;

  /// Permet d'obtenir le nombre de logements publiés
  int get activePropertiesCount =>
      properties.where((p) => p.status.toUpperCase() == 'PUBLISHED').length;

  /// Permet d'obtenir le nombre de logements en brouillon
  int get draftPropertiesCount =>
      properties.where((p) => p.status.toUpperCase() == 'DRAFT').length;

  /// Permet d'obtenir le nombre de logements loués
  int get rentedPropertiesCount =>
      properties.where((p) => p.status.toUpperCase() == 'RENTED').length;

  /// Permet d'obtenir le nombre de logements suspendus
  int get suspendedPropertiesCount =>
      properties.where((p) => p.status.toUpperCase() == 'SUSPENDED').length;

  /// Somme des vues de tous les logements du bailleur
  int get totalViews =>
      properties.fold<int>(0, (sum, p) => sum + p.viewsCount);

  /// Somme des demandes de contact de tous les logements du bailleur
  int get totalInquiries =>
      properties.fold<int>(0, (sum, p) => sum + p.inquiriesCount);

  /// Nombre total de demandes de visite reçues
  int get totalVisitsCount => visits.length;

  /// Nombre de demandes de visite en attente
  int get pendingVisitsCount =>
      visits.where((v) => v.status.toUpperCase() == 'PENDING').length;

  /// Nombre de conversations actives
  int get totalConversationsCount => conversations.length;

  /// Nombre total de messages non lus
  int get unreadMessagesCount =>
      conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);

  /// 3 dernières demandes de visite réelles triées par date de création
  List<Visite> get recentVisits {
    final list = List<Visite>.from(visits);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(3).toList();
  }

  /// 3 dernières conversations réelles triées par date de dernier message
  List<ConversationModel> get recentConversations {
    final list = List<ConversationModel>.from(conversations);
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list.take(3).toList();
  }

  /// Logements les plus populaires (basé sur les vues et demandes d'information réelles)
  List<PropertyModel> get topProperties {
    final list = List<PropertyModel>.from(properties);
    list.sort((a, b) =>
        (b.viewsCount + b.inquiriesCount).compareTo(a.viewsCount + a.inquiriesCount));
    return list.take(3).toList();
  }

  /// Clone de l'objet
  DashboardSummaryModel copyWith({
    List<PropertyModel>? properties,
    List<Visite>? visits,
    List<ConversationModel>? conversations,
    int? unreadNotificationsCount,
  }) {
    return DashboardSummaryModel(
      properties: properties ?? this.properties,
      visits: visits ?? this.visits,
      conversations: conversations ?? this.conversations,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
    );
  }
}
