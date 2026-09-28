// Modèle d'équipement
class Equipement {
  final String id;
  final String nom;
  final String? description;
  final String? icone;
  final String categorie;
  final int ordre;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Equipement({
    required this.id,
    required this.nom,
    this.description,
    this.icone,
    required this.categorie,
    this.ordre = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Equipement copyWith({
    String? id,
    String? nom,
    String? description,
    String? icone,
    String? categorie,
    int? ordre,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Equipement(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      icone: icone ?? this.icone,
      categorie: categorie ?? this.categorie,
      ordre: ordre ?? this.ordre,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'icone': icone,
      'categorie': categorie,
      'ordre': ordre,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Equipement.fromMap(Map<String, dynamic> map) {
    return Equipement(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String?,
      icone: map['icone'] as String?,
      categorie: map['categorie'] as String,
      ordre: map['ordre'] as int? ?? 0,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Equipement.fromJson(String source) =>
      Equipement.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
