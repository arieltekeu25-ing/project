// Modèle d'historique
class Historique {
  final String id;
  final String utilisateurId;
  final String typeAction;
  final String? description;
  final String? entiteId;
  final String? entiteType;
  final String? donnees;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Historique({
    required this.id,
    required this.utilisateurId,
    required this.typeAction,
    this.description,
    this.entiteId,
    this.entiteType,
    this.donnees,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Historique copyWith({
    String? id,
    String? utilisateurId,
    String? typeAction,
    String? description,
    String? entiteId,
    String? entiteType,
    String? donnees,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Historique(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      typeAction: typeAction ?? this.typeAction,
      description: description ?? this.description,
      entiteId: entiteId ?? this.entiteId,
      entiteType: entiteType ?? this.entiteType,
      donnees: donnees ?? this.donnees,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'type_action': typeAction,
      'description': description,
      'entite_id': entiteId,
      'entite_type': entiteType,
      'donnees': donnees,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      typeAction: map['type_action'] as String,
      description: map['description'] as String?,
      entiteId: map['entite_id'] as String?,
      entiteType: map['entite_type'] as String?,
      donnees: map['donnees'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Historique.fromJson(String source) =>
      Historique.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Historique && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
