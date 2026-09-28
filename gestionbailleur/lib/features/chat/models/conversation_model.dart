import '../../home/models/property_model.dart';
import 'message_model.dart';

/// Modèle représentant une conversation réelle entre client et bailleur pour un logement
class ConversationModel {
  final String id;
  final String clientId;
  final String landlordId;
  final PropertyModel property;
  final String otherParticipantId;
  final String otherParticipantName;
  final String? otherParticipantAvatar;
  final String otherParticipantRole;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  ConversationModel({
    required this.id,
    required this.clientId,
    required this.landlordId,
    required this.property,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.otherParticipantAvatar,
    this.otherParticipantRole = 'CORRESPONDANT',
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    PropertyModel prop;
    if (json['property'] is Map<String, dynamic>) {
      prop = PropertyModel.fromJson(json['property'] as Map<String, dynamic>);
    } else {
      prop = PropertyModel(
        id: json['property_id']?.toString() ?? '',
        title: json['property_title'] ?? 'Logement',
        description: '',
        propertyType: 'APARTMENT',
        status: 'AVAILABLE',
        rentPrice: 0,
        surface: 0,
        rooms: 0,
        bedrooms: 0,
        bathrooms: 0,
        furnished: false,
        parking: false,
        balcony: false,
        terrace: false,
        elevator: false,
        garden: false,
        pool: false,
        airConditioning: false,
        heating: '',
        viewsCount: 0,
        inquiriesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        landlordName: '',
        landlordEmail: '',
      );
    }

    Map<String, dynamic>? otherPart = json['other_participant'] as Map<String, dynamic>?;

    // Essayer différents champs pour l'avatar
    String? avatarUrl = otherPart?['avatar']?.toString();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = otherPart?['profile_photo']?.toString();
    }
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = otherPart?['photo']?.toString();
    }
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = otherPart?['profile_picture']?.toString();
    }
    // Essayer dans un objet imbriqué 'profile' ou 'UserProfile'
    try {
      if (avatarUrl == null || avatarUrl.isEmpty) {
        final profile = otherPart?['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          avatarUrl = profile['avatar']?.toString() ?? 
                      profile['profile_photo']?.toString() ?? 
                      profile['photo']?.toString() ?? 
                      profile['profile_picture']?.toString();
        }
      }
      // Essayer dans un objet imbriqué 'user'
      if (avatarUrl == null || avatarUrl.isEmpty) {
        final user = otherPart?['user'] as Map<String, dynamic>?;
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

    MessageModel? lastMsg;
    if (json['last_message'] != null && json['last_message'] is Map<String, dynamic>) {
      lastMsg = MessageModel.fromJson(json['last_message'] as Map<String, dynamic>);
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      clientId: json['client']?.toString() ?? '',
      landlordId: json['landlord']?.toString() ?? '',
      property: prop,
      otherParticipantId: otherPart?['id']?.toString() ?? '',
      otherParticipantName: otherPart?['name'] ?? 'Correspondant',
      otherParticipantAvatar: avatarUrl,
      otherParticipantRole: otherPart?['role'] ?? 'CORRESPONDANT',
      lastMessage: lastMsg,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'landlord': landlordId,
      'property': property.toJson(),
      'other_participant': {
        'id': otherParticipantId,
        'name': otherParticipantName,
        'avatar': otherParticipantAvatar,
        'role': otherParticipantRole,
      },
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
    };
  }

  ConversationModel copyWith({
    String? id,
    String? clientId,
    String? landlordId,
    PropertyModel? property,
    String? otherParticipantId,
    String? otherParticipantName,
    String? otherParticipantAvatar,
    String? otherParticipantRole,
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      landlordId: landlordId ?? this.landlordId,
      property: property ?? this.property,
      otherParticipantId: otherParticipantId ?? this.otherParticipantId,
      otherParticipantName: otherParticipantName ?? this.otherParticipantName,
      otherParticipantAvatar: otherParticipantAvatar ?? this.otherParticipantAvatar,
      otherParticipantRole: otherParticipantRole ?? this.otherParticipantRole,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}
