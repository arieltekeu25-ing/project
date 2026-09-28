import 'dart:convert';

/// Modèle de conversation chatbot
class ChatbotConversation {
  final String id;
  final String utilisateurId;
  final String? titre;
  final String? contexte;
  final DateTime dateDerniereInteraction;
  final int nombreMessages;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  ChatbotConversation({
    required this.id,
    required this.utilisateurId,
    this.titre,
    this.contexte,
    required this.dateDerniereInteraction,
    this.nombreMessages = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  ChatbotConversation copyWith({
    String? id,
    String? utilisateurId,
    String? titre,
    String? contexte,
    DateTime? dateDerniereInteraction,
    int? nombreMessages,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return ChatbotConversation(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      titre: titre ?? this.titre,
      contexte: contexte ?? this.contexte,
      dateDerniereInteraction: dateDerniereInteraction ?? this.dateDerniereInteraction,
      nombreMessages: nombreMessages ?? this.nombreMessages,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'titre': titre,
      'contexte': contexte,
      'date_derniere_interaction': dateDerniereInteraction.toIso8601String(),
      'nombre_messages': nombreMessages,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory ChatbotConversation.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return now;
    }

    return ChatbotConversation(
      id: (map['id'] ?? '').toString(),
      utilisateurId: (map['utilisateur_id'] ?? map['user_id'] ?? map['user'] ?? '').toString(),
      titre: map['titre'] as String? ?? map['title'] as String?,
      contexte: map['contexte'] as String? ?? map['context'] as String?,
      dateDerniereInteraction: parseDate(map['date_derniere_interaction'] ?? map['updated_at']),
      nombreMessages: map['nombre_messages'] as int? ?? map['messages_count'] as int? ?? 0,
      statut: (map['statut'] ?? map['status'] ?? 'ACTIF').toString(),
      dateCreation: parseDate(map['date_creation'] ?? map['created_at']),
      dateModification: parseDate(map['date_modification'] ?? map['updated_at']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatbotConversation.fromJson(String source) =>
      ChatbotConversation.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatbotConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
