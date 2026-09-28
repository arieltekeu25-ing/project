import '../services/chatbot_api_service.dart';
import '../../../domain/models/chatbot_conversation.dart';
import '../../../domain/models/chatbot_message.dart';

class ChatbotRepository {
  final ChatbotApiService _apiService;

  ChatbotRepository({ChatbotApiService? apiService})
      : _apiService = apiService ?? ChatbotApiService();

  Future<List<ChatbotConversation>> getConversations() => _apiService.getConversations();

  Future<ChatbotConversation> createConversation({String? title}) =>
      _apiService.createConversation(title: title);

  Future<void> deleteConversation(String id) => _apiService.deleteConversation(id);

  Future<List<ChatbotMessage>> getMessages(String conversationId) =>
      _apiService.getMessages(conversationId);

  Future<Map<String, dynamic>> sendMessage(String text, {String? conversationId}) =>
      _apiService.sendMessage(text, conversationId: conversationId);
}
