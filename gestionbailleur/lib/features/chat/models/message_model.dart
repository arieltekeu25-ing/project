/// Modèle représentant un message de discussion
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String recipientId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.recipientId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.isMe = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Essayer différents champs pour l'avatar de l'expéditeur
    String? avatarUrl = json['sender_avatar']?.toString();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = json['sender_profile_photo']?.toString();
    }
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = json['sender_photo']?.toString();
    }
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = json['sender_profile_picture']?.toString();
    }
    // Essayer dans un objet imbriqué 'sender' ou 'user'
    try {
      if (avatarUrl == null || avatarUrl.isEmpty) {
        final sender = json['sender'] as Map<String, dynamic>?;
        if (sender != null) {
          avatarUrl = sender['avatar']?.toString() ?? 
                      sender['profile_photo']?.toString() ?? 
                      sender['photo']?.toString() ?? 
                      sender['profile_picture']?.toString();
        }
      }
      if (avatarUrl == null || avatarUrl.isEmpty) {
        final user = json['user'] as Map<String, dynamic>?;
        if (user != null) {
          avatarUrl = user['avatar']?.toString() ?? 
                      user['profile_photo']?.toString() ?? 
                      user['photo']?.toString() ?? 
                      user['profile_picture']?.toString();
        }
      }
    } catch (e) {
      // Ignorer les erreurs de parsing imbriqué
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation']?.toString() ?? json['conversation_id']?.toString() ?? '',
      senderId: json['sender']?.toString() ?? json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'] ?? 'Utilisateur',
      senderAvatar: avatarUrl,
      recipientId: json['recipient']?.toString() ?? json['recipient_id']?.toString() ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMe: json['is_me'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversationId,
      'sender': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'recipient': recipientId,
      'content': content,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_me': isMe,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? recipientId,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    bool? isMe,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
    );
  }
}
