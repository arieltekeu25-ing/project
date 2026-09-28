import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';
import '../services/chat_websocket_service.dart';

// -----------------------------------------------------------------------------
// REPOSITORY PROVIDER
// -----------------------------------------------------------------------------
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// -----------------------------------------------------------------------------
// MESSAGES / CONVERSATIONS LIST STATE & PROVIDER
// -----------------------------------------------------------------------------
class MessagesState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? errorMessage;
  final int totalUnreadCount;
  final bool hasAttemptedFetch;

  const MessagesState({
    this.conversations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalUnreadCount = 0,
    this.hasAttemptedFetch = false,
  });

  MessagesState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? errorMessage,
    int? totalUnreadCount,
    bool? hasAttemptedFetch,
    bool clearError = false,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
    );
  }
}

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return MessagesNotifier(repository, ref);
});

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ChatRepository _repository;
  final Ref _ref;

  MessagesNotifier(this._repository, this._ref) : super(const MessagesState());

  /// Charger la liste des conversations réelles
  Future<void> loadConversations({bool forceRefresh = false}) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) {
      state = state.copyWith(
        conversations: [],
        totalUnreadCount: 0,
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
      return;
    }

    if (!forceRefresh && state.hasAttemptedFetch && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final conversations = await _repository.getConversations();
      final totalUnread = conversations.fold<int>(
        0,
        (sum, c) => sum + c.unreadCount,
      );

      state = state.copyWith(
        conversations: conversations,
        totalUnreadCount: totalUnread,
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  /// Charger uniquement le nombre total de messages non lus
  Future<void> refreshUnreadCount() async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return;

    final unread = await _repository.getUnreadCount();
    state = state.copyWith(totalUnreadCount: unread);
  }

  /// Démarrer ou récupérer une conversation pour un logement
  Future<ConversationModel?> getOrCreateConversationForProperty(String propertyId) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return null;

    try {
      final conversation = await _repository.getOrCreateConversation(propertyId);
      await loadConversations(forceRefresh: true);
      return conversation;
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer une conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final success = await _repository.deleteConversation(conversationId);
      if (success) {
        final updatedConversations = state.conversations.where((c) => c.id != conversationId).toList();
        final totalUnread = updatedConversations.fold<int>(
          0,
          (sum, c) => sum + c.unreadCount,
        );
        state = state.copyWith(
          conversations: updatedConversations,
          totalUnreadCount: totalUnread,
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Mettre à jour une conversation (ex: archiver)
  Future<ConversationModel?> updateConversation(String conversationId, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateConversation(conversationId, data);
      final index = state.conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final updatedConversations = List<ConversationModel>.from(state.conversations);
        updatedConversations[index] = updated;
        state = state.copyWith(conversations: updatedConversations);
      }
      return updated;
    } catch (e) {
      return null;
    }
  }

  /// Marquer une conversation comme lue
  Future<void> markAsRead(String conversationId) async {
    try {
      await _repository.markAsRead(conversationId);
      final index = state.conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final updatedConversations = List<ConversationModel>.from(state.conversations);
        updatedConversations[index] = updatedConversations[index].copyWith(unreadCount: 0);
        final totalUnread = updatedConversations.fold<int>(
          0,
          (sum, c) => sum + c.unreadCount,
        );
        state = state.copyWith(
          conversations: updatedConversations,
          totalUnreadCount: totalUnread,
        );
      }
    } catch (e) {
      // Ignorer
    }
  }

  /// Archiver une conversation
  Future<bool> archiveConversation(String conversationId) async {
    try {
      await _repository.updateConversation(conversationId, {'archived': true});
      final updatedConversations = state.conversations.where((c) => c.id != conversationId).toList();
      final totalUnread = updatedConversations.fold<int>(
        0,
        (sum, c) => sum + c.unreadCount,
      );
      state = state.copyWith(
        conversations: updatedConversations,
        totalUnreadCount: totalUnread,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('Non autorisé') || str.contains('Unauthorized')) {
      return 'Veuillez vous connecter pour accéder aux messages.';
    }
    if (str.contains('SocketException') || str.contains('NetworkException')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion internet.';
    }
    return 'Une erreur est survenue lors du chargement de vos messages.';
  }
}

// -----------------------------------------------------------------------------
// CHAT THREAD STATE & PROVIDER (ACTIVE CONVERSATION)
// -----------------------------------------------------------------------------
class ChatThreadState {
  final ConversationModel? conversation;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String? sendError;

  const ChatThreadState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.sendError,
  });

  ChatThreadState copyWith({
    ConversationModel? conversation,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    String? sendError,
    bool clearError = false,
    bool clearSendError = false,
  }) {
    return ChatThreadState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sendError: clearSendError ? null : (sendError ?? this.sendError),
    );
  }
}

final chatThreadProvider =
    StateNotifierProvider<ChatThreadNotifier, ChatThreadState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatThreadNotifier(repository, ref);
});

class ChatThreadNotifier extends StateNotifier<ChatThreadState> {
  final ChatRepository _repository;
  final Ref _ref;
  final ChatWebSocketService _wsService = ChatWebSocketService.instance;

  ChatThreadNotifier(this._repository, this._ref) : super(const ChatThreadState());

  /// Charger le fil de discussion complet d'une conversation par ID
  Future<void> loadConversationAndMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSendError: true);

    try {
      final conversation = await _repository.getConversationById(conversationId);
      final messages = await _repository.getMessages(conversationId);

      state = state.copyWith(
        conversation: conversation,
        messages: messages,
        isLoading: false,
        clearError: true,
      );

      // Connecter l'abstraction WebSocket
      _wsService.connect(conversationId: conversationId, token: '');

      // Marquer automatiquement comme lu
      await markAsRead(conversationId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  /// Envoyer un message dans la conversation active
  Future<bool> sendMessage(String content) async {
    final activeConv = state.conversation;
    if (activeConv == null || content.trim().isEmpty) return false;

    state = state.copyWith(isSending: true, clearSendError: true);

    try {
      final sentMessage = await _repository.sendMessage(
        activeConv.id,
        content.trim(),
      );

      final updatedMessages = List<MessageModel>.from(state.messages)..add(sentMessage);

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        clearSendError: true,
      );

      // Émettre sur l'abstraction WebSocket
      _wsService.sendRealtimeMessage(sentMessage.toJson());

      // Rafrachir les conversations globales
      _ref.read(messagesProvider.notifier).loadConversations(forceRefresh: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        sendError: _cleanErrorMessage(e),
      );
      return false;
    }
  }

  /// Marquer les messages comme lus
  Future<void> markAsRead(String conversationId) async {
    try {
      await _repository.markAsRead(conversationId);

      final updatedMessages = state.messages.map((m) {
        return m.isMe ? m : m.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(messages: updatedMessages);

      // Rafraîchir les compteurs globaux
      _ref.read(messagesProvider.notifier).refreshUnreadCount();
    } catch (e) {
      // Ignorer
    }
  }

  /// Supprimer un message spécifique
  Future<bool> deleteMessage(String messageId) async {
    final activeConv = state.conversation;
    if (activeConv == null) return false;

    try {
      final success = await _repository.deleteMessage(activeConv.id, messageId);
      if (success) {
        final updatedMessages = state.messages.where((m) => m.id != messageId).toList();
        state = state.copyWith(messages: updatedMessages);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('SocketException') || str.contains('NetworkException')) {
      return 'Impossible d\'envoyer le message. Vérifiez votre connexion internet.';
    }
    return 'Erreur lors de l\'envoi du message.';
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
