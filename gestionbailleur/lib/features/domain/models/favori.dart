// Modèle de favori
class Favori {
  final String id;
  final String utilisateurId;
  final String logementId;
  final String? notes;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Favori({
    required this.id,
    required this.utilisateurId,
    required this.logementId,
    this.notes,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Favori copyWith({
    String? id,
    String? utilisateurId,
    String? logementId,
    String? notes,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Favori(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      logementId: logementId ?? this.logementId,
      notes: notes ?? this.notes,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'logement_id': logementId,
      'notes': notes,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Favori.fromMap(Map<String, dynamic> map) {
    return Favori(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      logementId: map['logement_id'] as String,
      notes: map['notes'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Favori.fromJson(String source) =>
      Favori.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favori && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
