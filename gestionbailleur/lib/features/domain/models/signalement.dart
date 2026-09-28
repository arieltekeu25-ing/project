// Modèle de signalement
class Signalement {
  final String id;
  final String auteurId;
  final String entiteId;
  final String entiteType;
  final String motif;
  final String? description;
  final String statutSignalement;
  final String? reponseAdmin;
  final DateTime? dateTraitement;
  final String? traiteParId;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Signalement({
    required this.id,
    required this.auteurId,
    required this.entiteId,
    required this.entiteType,
    required this.motif,
    this.description,
    this.statutSignalement = 'en_attente',
    this.reponseAdmin,
    this.dateTraitement,
    this.traiteParId,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Signalement copyWith({
    String? id,
    String? auteurId,
    String? entiteId,
    String? entiteType,
    String? motif,
    String? description,
    String? statutSignalement,
    String? reponseAdmin,
    DateTime? dateTraitement,
    String? traiteParId,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Signalement(
      id: id ?? this.id,
      auteurId: auteurId ?? this.auteurId,
      entiteId: entiteId ?? this.entiteId,
      entiteType: entiteType ?? this.entiteType,
      motif: motif ?? this.motif,
      description: description ?? this.description,
      statutSignalement: statutSignalement ?? this.statutSignalement,
      reponseAdmin: reponseAdmin ?? this.reponseAdmin,
      dateTraitement: dateTraitement ?? this.dateTraitement,
      traiteParId: traiteParId ?? this.traiteParId,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auteur_id': auteurId,
      'entite_id': entiteId,
      'entite_type': entiteType,
      'motif': motif,
      'description': description,
      'statut_signalement': statutSignalement,
      'reponse_admin': reponseAdmin,
      'date_traitement': dateTraitement?.toIso8601String(),
      'traite_par_id': traiteParId,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Signalement.fromMap(Map<String, dynamic> map) {
    return Signalement(
      id: map['id'] as String,
      auteurId: map['auteur_id'] as String,
      entiteId: map['entite_id'] as String,
      entiteType: map['entite_type'] as String,
      motif: map['motif'] as String,
      description: map['description'] as String?,
      statutSignalement: map['statut_signalement'] as String? ?? 'en_attente',
      reponseAdmin: map['reponse_admin'] as String?,
      dateTraitement: map['date_traitement'] != null
          ? DateTime.parse(map['date_traitement'] as String)
          : null,
      traiteParId: map['traite_par_id'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Signalement.fromJson(String source) =>
      Signalement.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Signalement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
