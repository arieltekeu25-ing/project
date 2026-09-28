// Modèle de message
class Message {
  final String id;
  final String conversationId;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final String? pieceJointeUrl;
  final String type;
  final bool estLu;
  final DateTime dateLecture;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Message({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    this.pieceJointeUrl,
    required this.type,
    this.estLu = false,
    required this.dateLecture,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? expediteurId,
    String? destinataireId,
    String? contenu,
    String? pieceJointeUrl,
    String? type,
    bool? estLu,
    DateTime? dateLecture,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      expediteurId: expediteurId ?? this.expediteurId,
      destinataireId: destinataireId ?? this.destinataireId,
      contenu: contenu ?? this.contenu,
      pieceJointeUrl: pieceJointeUrl ?? this.pieceJointeUrl,
      type: type ?? this.type,
      estLu: estLu ?? this.estLu,
      dateLecture: dateLecture ?? this.dateLecture,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'expediteur_id': expediteurId,
      'destinataire_id': destinataireId,
      'contenu': contenu,
      'piece_jointe_url': pieceJointeUrl,
      'type': type,
      'est_lu': estLu,
      'date_lecture': dateLecture.toIso8601String(),
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      expediteurId: map['expediteur_id'] as String,
      destinataireId: map['destinataire_id'] as String,
      contenu: map['contenu'] as String,
      pieceJointeUrl: map['piece_jointe_url'] as String?,
      type: map['type'] as String,
      estLu: map['est_lu'] as bool? ?? false,
      dateLecture: DateTime.parse(map['date_lecture'] as String),
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Message.fromJson(String source) =>
      Message.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
