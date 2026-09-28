import '../../../core/services/api_service.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Repository pour la gestion des conversations et des messages réels
class ChatRepository {
  final ApiService _apiService;

  ChatRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Récupérer les conversations réelles de l'utilisateur
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiService.get(
        '/api/v1/messages/conversations/',
        requireAuth: true,
      );

      List<ConversationModel> conversations = [];
      if (response is List) {
        conversations = response.map((json) => ConversationModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        conversations = results.map((json) => ConversationModel.fromJson(json)).toList();
      }
      return conversations;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Créer ou récupérer une conversation pour un logement donné
  Future<ConversationModel> getOrCreateConversation(String propertyId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/messages/conversations/',
        body: {'property_id': propertyId},
        requireAuth: true,
      );

      return ConversationModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir les détails d'une conversation par ID
  Future<ConversationModel> getConversationById(String conversationId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/messages/conversations/$conversationId/',
        requireAuth: true,
      );

      return ConversationModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les messages réels d'une conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/messages/conversations/$conversationId/messages/',
        requireAuth: true,
      );

      List<MessageModel> messages = [];
      if (response is List) {
        messages = response.map((json) => MessageModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        messages = results.map((json) => MessageModel.fromJson(json)).toList();
      }
      return messages;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Envoyer un nouveau message dans une conversation
  Future<MessageModel> sendMessage(String conversationId, String content) async {
    try {
      final response = await _apiService.post(
        '/api/v1/messages/conversations/$conversationId/messages/',
        body: {'content': content},
        requireAuth: true,
      );

      return MessageModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Marquer les messages d'une conversation comme lus
  Future<int> markAsRead(String conversationId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/messages/conversations/$conversationId/read/',
        requireAuth: true,
      );

      if (response is Map && response.containsKey('read_count')) {
        return (response['read_count'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Obtenir le nombre total de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/api/v1/messages/unread-count/',
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

  /// Supprimer un message spécifique (suppression locale uniquement)
  Future<bool> deleteMessage(String conversationId, String messageId) async {
    try {
      // Pour l'instant, nous supprimons seulement localement dans le provider
      // car il n'y a pas d'endpoint backend pour la suppression des messages
      // Cette méthode retourne true pour permettre la suppression locale
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer une conversation entière (suppression locale uniquement)
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // Pour l'instant, nous supprimons seulement localement dans le provider
      // car il n'y a pas d'endpoint backend pour la suppression des conversations
      // Cette méthode retourne true pour permettre la suppression locale
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour une conversation (ex: archiver)
  Future<ConversationModel> updateConversation(String conversationId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/api/v1/messages/conversations/$conversationId/',
        body: data,
        requireAuth: true,
      );
      return ConversationModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
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
