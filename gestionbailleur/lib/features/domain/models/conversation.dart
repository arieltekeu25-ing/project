// Modèle de conversation
class Conversation {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String logementId;
  final String? dernierMessage;
  final DateTime dateDernierMessage;
  final int nombreMessages;
  final int nombreMessagesNonLus;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Conversation({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.logementId,
    this.dernierMessage,
    required this.dateDernierMessage,
    this.nombreMessages = 0,
    this.nombreMessagesNonLus = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Conversation copyWith({
    String? id,
    String? participant1Id,
    String? participant2Id,
    String? logementId,
    String? dernierMessage,
    DateTime? dateDernierMessage,
    int? nombreMessages,
    int? nombreMessagesNonLus,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Conversation(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      logementId: logementId ?? this.logementId,
      dernierMessage: dernierMessage ?? this.dernierMessage,
      dateDernierMessage: dateDernierMessage ?? this.dateDernierMessage,
      nombreMessages: nombreMessages ?? this.nombreMessages,
      nombreMessagesNonLus: nombreMessagesNonLus ?? this.nombreMessagesNonLus,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant1_id': participant1Id,
      'participant2_id': participant2Id,
      'logement_id': logementId,
      'dernier_message': dernierMessage,
      'date_dernier_message': dateDernierMessage.toIso8601String(),
      'nombre_messages': nombreMessages,
      'nombre_messages_non_lus': nombreMessagesNonLus,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      participant1Id: map['participant1_id'] as String,
      participant2Id: map['participant2_id'] as String,
      logementId: map['logement_id'] as String,
      dernierMessage: map['dernier_message'] as String?,
      dateDernierMessage: DateTime.parse(map['date_dernier_message'] as String),
      nombreMessages: map['nombre_messages'] as int? ?? 0,
      nombreMessagesNonLus: map['nombre_messages_non_lus'] as int? ?? 0,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Conversation.fromJson(String source) =>
      Conversation.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
