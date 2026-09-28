// Modèle de document de vérification
class DocumentVerification {
  final String id;
  final String utilisateurId;
  final String typeDocument;
  final String numeroDocument;
  final String? urlDocument;
  final String? urlRecto;
  final String? urlVerso;
  final DateTime dateExpiration;
  final String statutVerification;
  final String? commentaire;
  final DateTime? dateVerification;
  final String? verifieParId;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  DocumentVerification({
    required this.id,
    required this.utilisateurId,
    required this.typeDocument,
    required this.numeroDocument,
    this.urlDocument,
    this.urlRecto,
    this.urlVerso,
    required this.dateExpiration,
    this.statutVerification = 'en_attente',
    this.commentaire,
    this.dateVerification,
    this.verifieParId,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  DocumentVerification copyWith({
    String? id,
    String? utilisateurId,
    String? typeDocument,
    String? numeroDocument,
    String? urlDocument,
    String? urlRecto,
    String? urlVerso,
    DateTime? dateExpiration,
    String? statutVerification,
    String? commentaire,
    DateTime? dateVerification,
    String? verifieParId,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return DocumentVerification(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      typeDocument: typeDocument ?? this.typeDocument,
      numeroDocument: numeroDocument ?? this.numeroDocument,
      urlDocument: urlDocument ?? this.urlDocument,
      urlRecto: urlRecto ?? this.urlRecto,
      urlVerso: urlVerso ?? this.urlVerso,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      statutVerification: statutVerification ?? this.statutVerification,
      commentaire: commentaire ?? this.commentaire,
      dateVerification: dateVerification ?? this.dateVerification,
      verifieParId: verifieParId ?? this.verifieParId,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'type_document': typeDocument,
      'numero_document': numeroDocument,
      'url_document': urlDocument,
      'url_recto': urlRecto,
      'url_verso': urlVerso,
      'date_expiration': dateExpiration.toIso8601String(),
      'statut_verification': statutVerification,
      'commentaire': commentaire,
      'date_verification': dateVerification?.toIso8601String(),
      'verifie_par_id': verifieParId,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory DocumentVerification.fromMap(Map<String, dynamic> map) {
    return DocumentVerification(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      typeDocument: map['type_document'] as String,
      numeroDocument: map['numero_document'] as String,
      urlDocument: map['url_document'] as String?,
      urlRecto: map['url_recto'] as String?,
      urlVerso: map['url_verso'] as String?,
      dateExpiration: DateTime.parse(map['date_expiration'] as String),
      statutVerification: map['statut_verification'] as String? ?? 'en_attente',
      commentaire: map['commentaire'] as String?,
      dateVerification: map['date_verification'] != null
          ? DateTime.parse(map['date_verification'] as String)
          : null,
      verifieParId: map['verifie_par_id'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory DocumentVerification.fromJson(String source) =>
      DocumentVerification.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentVerification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
