import 'dart:convert';

/// Modèle de message chatbot
class ChatbotMessage {
  final String id;
  final String conversationId;
  final String contenu;
  final String role;
  final String? contexte;
  final String? donnees;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  ChatbotMessage({
    required this.id,
    required this.conversationId,
    required this.contenu,
    required this.role,
    this.contexte,
    this.donnees,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  ChatbotMessage copyWith({
    String? id,
    String? conversationId,
    String? contenu,
    String? role,
    String? contexte,
    String? donnees,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return ChatbotMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      contenu: contenu ?? this.contenu,
      role: role ?? this.role,
      contexte: contexte ?? this.contexte,
      donnees: donnees ?? this.donnees,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'contenu': contenu,
      'role': role,
      'contexte': contexte,
      'donnees': donnees,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory ChatbotMessage.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return now;
    }

    String? parseDonnees(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      try {
        return jsonEncode(val);
      } catch (_) {
        return val.toString();
      }
    }

    return ChatbotMessage(
      id: (map['id'] ?? '').toString(),
      conversationId: (map['conversation_id'] ?? map['conversation'] ?? '').toString(),
      contenu: (map['contenu'] ?? map['content'] ?? '').toString(),
      role: (map['role'] ?? 'assistant').toString(),
      contexte: map['contexte'] as String? ?? map['context'] as String?,
      donnees: parseDonnees(map['donnees'] ?? map['metadata']),
      statut: (map['statut'] ?? map['status'] ?? 'ENVOYE').toString(),
      dateCreation: parseDate(map['date_creation'] ?? map['created_at']),
      dateModification: parseDate(map['date_modification'] ?? map['updated_at']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatbotMessage.fromJson(String source) =>
      ChatbotMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatbotMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
