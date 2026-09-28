import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';

/// Service d'abstraction WebSocket préparé pour Django Channels
class ChatWebSocketService {
  static ChatWebSocketService? _instance;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _isConnected = false;
  String? _currentConversationId;

  ChatWebSocketService._();

  static ChatWebSocketService get instance {
    _instance ??= ChatWebSocketService._();
    return _instance!;
  }

  /// Flux de réception des événements temps réel
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _isConnected;
  String? get currentConversationId => _currentConversationId;

  /// Établir la connexion WebSocket avec Django Channels
  Future<void> connect({
    required String conversationId,
    required String token,
  }) async {
    if (_isConnected && _currentConversationId == conversationId) return;

    _currentConversationId = conversationId;
    
    // Obtenir l'URL WebSocket à partir de la configuration API
    final wsBaseUrl = AppConfig.apiBaseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final wsUrl = '$wsBaseUrl/ws/chat/$conversationId/?token=$token';

    if (kDebugMode) {
      print('🌐 WebSocket Channels préparé sur : $wsUrl');
    }

    // Le WebSocket réel utilisera web_socket_channel lors de l'activation du serveur Django Channels.
    _isConnected = true;
  }

  /// Émettre un événement temps réel sur le WebSocket
  void sendRealtimeMessage(Map<String, dynamic> data) {
    if (!_isConnected) return;
    if (kDebugMode) {
      print('📤 Émission message WS: $data');
    }
  }

  /// Fermer proprement la connexion WebSocket
  void disconnect() {
    _isConnected = false;
    _currentConversationId = null;
    if (kDebugMode) {
      print('🔌 Déconnexion WebSocket');
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
