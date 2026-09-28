// Modèle d'avis
class Avis {
  final String id;
  final String utilisateurId;
  final String logementId;
  final int note;
  final String? commentaire;
  final String? reponseBailleur;
  final DateTime dateReponse;
  final bool estVerifie;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Avis({
    required this.id,
    required this.utilisateurId,
    required this.logementId,
    required this.note,
    this.commentaire,
    this.reponseBailleur,
    required this.dateReponse,
    this.estVerifie = false,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Avis copyWith({
    String? id,
    String? utilisateurId,
    String? logementId,
    int? note,
    String? commentaire,
    String? reponseBailleur,
    DateTime? dateReponse,
    bool? estVerifie,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Avis(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      logementId: logementId ?? this.logementId,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      reponseBailleur: reponseBailleur ?? this.reponseBailleur,
      dateReponse: dateReponse ?? this.dateReponse,
      estVerifie: estVerifie ?? this.estVerifie,
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
      'note': note,
      'commentaire': commentaire,
      'reponse_bailleur': reponseBailleur,
      'date_reponse': dateReponse.toIso8601String(),
      'est_verifie': estVerifie,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Avis.fromMap(Map<String, dynamic> map) {
    return Avis(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      logementId: map['logement_id'] as String,
      note: map['note'] as int,
      commentaire: map['commentaire'] as String?,
      reponseBailleur: map['reponse_bailleur'] as String?,
      dateReponse: DateTime.parse(map['date_reponse'] as String),
      estVerifie: map['est_verifie'] as bool? ?? false,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Avis.fromJson(String source) =>
      Avis.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Avis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
