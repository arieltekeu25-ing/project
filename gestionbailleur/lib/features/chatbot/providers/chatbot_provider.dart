import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/chatbot_repository.dart';
import '../../domain/models/chatbot_conversation.dart';
import '../../domain/models/chatbot_message.dart';
import '../../../core/network/network_exceptions.dart';

class ChatbotState {
  final List<ChatbotConversation> conversations;
  final ChatbotConversation? currentConversation;
  final List<ChatbotMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? errorMessage;

  const ChatbotState({
    this.conversations = const [],
    this.currentConversation,
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.errorMessage,
  });

  ChatbotState copyWith({
    List<ChatbotConversation>? conversations,
    ChatbotConversation? currentConversation,
    bool clearCurrentConversation = false,
    List<ChatbotMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatbotState(
      conversations: conversations ?? this.conversations,
      currentConversation: clearCurrentConversation
          ? null
          : (currentConversation ?? this.currentConversation),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotRepository _repository;

  ChatbotNotifier(this._repository) : super(const ChatbotState()) {
    loadConversations();
  }

  /// Charger la liste des conversations
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations = await _repository.getConversations();
      ChatbotConversation? active = state.currentConversation;
      
      if (conversations.isNotEmpty) {
        active = active ?? conversations.first;
      }

      state = state.copyWith(
        conversations: conversations,
        currentConversation: active,
        isLoading: false,
      );

      if (active != null) {
        await loadMessages(active.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger l\'historique des conversations.',
      );
    }
  }

  /// Sélectionner une conversation et charger ses messages
  Future<void> selectConversation(ChatbotConversation conversation) async {
    state = state.copyWith(currentConversation: conversation, clearError: true);
    await loadMessages(conversation.id);
  }

  /// Démarrer une nouvelle conversation
  void startNewConversation() {
    state = state.copyWith(
      clearCurrentConversation: true,
      messages: [],
      clearError: true,
    );
  }

  /// Charger les messages d'une conversation spécifique
  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final messages = await _repository.getMessages(conversationId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du chargement des messages.',
      );
    }
  }

  /// Supprimer une conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      final updatedList = state.conversations
          .where((c) => c.id != conversationId)
          .toList();

      bool isCurrentDeleted = state.currentConversation?.id == conversationId;
      ChatbotConversation? nextConv = isCurrentDeleted
          ? (updatedList.isNotEmpty ? updatedList.first : null)
          : state.currentConversation;

      state = state.copyWith(
        conversations: updatedList,
        currentConversation: nextConv,
        clearCurrentConversation: nextConv == null,
      );

      if (nextConv != null && isCurrentDeleted) {
        await loadMessages(nextConv.id);
      } else if (nextConv == null) {
        state = state.copyWith(messages: []);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors de la suppression de la conversation.',
      );
    }
  }

  /// Envoyer un message à l'IA
  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Message utilisateur optimiste
    final userMsg = ChatbotMessage(
      id: tempId,
      conversationId: state.currentConversation?.id ?? '',
      contenu: cleanText,
      role: 'user',
      statut: 'ENVOYE',
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      clearError: true,
    );

    try {
      final result = await _repository.sendMessage(
        cleanText,
        conversationId: state.currentConversation?.id,
      );

      final newConv = result['conversation'] as ChatbotConversation;
      final aiMsg = result['aiMessage'] as ChatbotMessage;
      final confirmUserMsg = result['userMessage'] as ChatbotMessage;

      // Mettre à jour la liste des messages
      final updatedMessages = state.messages
          .map((m) => m.id == tempId ? confirmUserMsg : m)
          .toList();
      updatedMessages.add(aiMsg);

      // Mettre à jour la liste des conversations
      final exists = state.conversations.any((c) => c.id == newConv.id);
      List<ChatbotConversation> updatedConversations;
      if (exists) {
        updatedConversations = state.conversations
            .map((c) => c.id == newConv.id ? newConv : c)
            .toList();
      } else {
        updatedConversations = [newConv, ...state.conversations];
      }

      state = state.copyWith(
        conversations: updatedConversations,
        currentConversation: newConv,
        messages: updatedMessages,
        isTyping: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Chatbot Error: $e');
      }
      String message = 'Le service IA est momentanément indisponible. Veuillez réessayer.';
      if (e is UnauthorizedException) {
        message = 'Session expirée. Veuillez vous reconnecter.';
      } else if (e is NetworkException) {
        message = e.message;
      }
      state = state.copyWith(
        isTyping: false,
        errorMessage: message,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider du repository Chatbot
final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotRepository();
});

/// Provider d'état du Chatbot
final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  final repo = ref.watch(chatbotRepositoryProvider);
  return ChatbotNotifier(repo);
});
