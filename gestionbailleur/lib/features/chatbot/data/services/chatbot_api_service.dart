import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../domain/models/chatbot_conversation.dart';
import '../../../domain/models/chatbot_message.dart';

class ChatbotApiService {
  final ApiService _apiService = ApiService.instance;

  /// Récupérer la liste des conversations du chatbot pour l'utilisateur
  Future<List<ChatbotConversation>> getConversations() async {
    final response = await _apiService.get(
      ApiEndpoints.chatbotConversations,
      requireAuth: true,
    );
    
    List<dynamic> list;
    if (response is List) {
      list = response;
    } else if (response is Map<String, dynamic> && response.containsKey('results')) {
      list = response['results'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((json) => ChatbotConversation.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  /// Créer une nouvelle conversation
  Future<ChatbotConversation> createConversation({String? title}) async {
    final response = await _apiService.post(
      ApiEndpoints.chatbotConversations,
      body: {
        if (title != null) 'titre': title,
      },
      requireAuth: true,
    );
    return ChatbotConversation.fromMap(response as Map<String, dynamic>);
  }

  /// Supprimer une conversation (soft delete)
  Future<void> deleteConversation(String id) async {
    await _apiService.delete(
      ApiEndpoints.chatbotConversationDetail(id),
      requireAuth: true,
    );
  }

  /// Récupérer la liste des messages d'une conversation
  Future<List<ChatbotMessage>> getMessages(String conversationId) async {
    final response = await _apiService.get(
      ApiEndpoints.chatbotMessages(conversationId),
      requireAuth: true,
    );
    
    List<dynamic> list;
    if (response is List) {
      list = response;
    } else if (response is Map<String, dynamic> && response.containsKey('results')) {
      list = response['results'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((json) => ChatbotMessage.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  /// Envoyer un message à l'IA et recevoir la réponse générée
  Future<Map<String, dynamic>> sendMessage(String text, {String? conversationId}) async {
    final payload = <String, dynamic>{
      'message': text,
      if (conversationId != null && conversationId.isNotEmpty)
        'conversation_id': conversationId,
    };

    final response = await _apiService.post(
      ApiEndpoints.chatbotSend,
      body: payload,
      requireAuth: false,
    );

    final data = response as Map<String, dynamic>;

    final conversation = ChatbotConversation.fromMap(data['conversation'] as Map<String, dynamic>);
    final userMessage = ChatbotMessage.fromMap(data['user_message'] as Map<String, dynamic>);
    final aiMessage = ChatbotMessage.fromMap(data['ai_message'] as Map<String, dynamic>);

    return {
      'conversation': conversation,
      'userMessage': userMessage,
      'aiMessage': aiMessage,
    };
  }
}
