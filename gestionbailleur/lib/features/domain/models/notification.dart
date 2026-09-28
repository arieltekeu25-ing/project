// Modèle de notification
class Notification {
  final String id;
  final String utilisateurId;
  final String titre;
  final String message;
  final String? lien;
  final String type;
  final bool estLue;
  final DateTime dateLecture;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Notification({
    required this.id,
    required this.utilisateurId,
    required this.titre,
    required this.message,
    this.lien,
    required this.type,
    this.estLue = false,
    required this.dateLecture,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Notification copyWith({
    String? id,
    String? utilisateurId,
    String? titre,
    String? message,
    String? lien,
    String? type,
    bool? estLue,
    DateTime? dateLecture,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Notification(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      lien: lien ?? this.lien,
      type: type ?? this.type,
      estLue: estLue ?? this.estLue,
      dateLecture: dateLecture ?? this.dateLecture,
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
      'message': message,
      'lien': lien,
      'type': type,
      'est_lue': estLue,
      'date_lecture': dateLecture.toIso8601String(),
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      titre: map['titre'] as String,
      message: map['message'] as String,
      lien: map['lien'] as String?,
      type: map['type'] as String,
      estLue: map['est_lue'] as bool? ?? false,
      dateLecture: DateTime.parse(map['date_lecture'] as String),
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Notification.fromJson(String source) =>
      Notification.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
