// Modèle de bailleur (propriétaire)
class Bailleur {
  final String id;
  final String utilisateurId;
  final String? raisonSociale;
  final String? numeroRegistreCommerce;
  final String? numeroContribuable;
  final String? adresseSiege;
  final String? siteWeb;
  final String? description;
  final String? telephoneProfessionnel;
  final String? emailProfessionnel;
  final List<String> biens;
  final List<String> documentsJuridiques;
  final bool estProfessionnel;
  final String statutVerification;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Bailleur({
    required this.id,
    required this.utilisateurId,
    this.raisonSociale,
    this.numeroRegistreCommerce,
    this.numeroContribuable,
    this.adresseSiege,
    this.siteWeb,
    this.description,
    this.telephoneProfessionnel,
    this.emailProfessionnel,
    this.biens = const [],
    this.documentsJuridiques = const [],
    this.estProfessionnel = false,
    this.statutVerification = 'en_attente',
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Bailleur copyWith({
    String? id,
    String? utilisateurId,
    String? raisonSociale,
    String? numeroRegistreCommerce,
    String? numeroContribuable,
    String? adresseSiege,
    String? siteWeb,
    String? description,
    String? telephoneProfessionnel,
    String? emailProfessionnel,
    List<String>? biens,
    List<String>? documentsJuridiques,
    bool? estProfessionnel,
    String? statutVerification,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Bailleur(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      raisonSociale: raisonSociale ?? this.raisonSociale,
      numeroRegistreCommerce: numeroRegistreCommerce ?? this.numeroRegistreCommerce,
      numeroContribuable: numeroContribuable ?? this.numeroContribuable,
      adresseSiege: adresseSiege ?? this.adresseSiege,
      siteWeb: siteWeb ?? this.siteWeb,
      description: description ?? this.description,
      telephoneProfessionnel: telephoneProfessionnel ?? this.telephoneProfessionnel,
      emailProfessionnel: emailProfessionnel ?? this.emailProfessionnel,
      biens: biens ?? this.biens,
      documentsJuridiques: documentsJuridiques ?? this.documentsJuridiques,
      estProfessionnel: estProfessionnel ?? this.estProfessionnel,
      statutVerification: statutVerification ?? this.statutVerification,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'raison_sociale': raisonSociale,
      'numero_registre_commerce': numeroRegistreCommerce,
      'numero_contribuable': numeroContribuable,
      'adresse_siege': adresseSiege,
      'site_web': siteWeb,
      'description': description,
      'telephone_professionnel': telephoneProfessionnel,
      'email_professionnel': emailProfessionnel,
      'biens': biens,
      'documents_juridiques': documentsJuridiques,
      'est_professionnel': estProfessionnel,
      'statut_verification': statutVerification,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Bailleur.fromMap(Map<String, dynamic> map) {
    return Bailleur(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      raisonSociale: map['raison_sociale'] as String?,
      numeroRegistreCommerce: map['numero_registre_commerce'] as String?,
      numeroContribuable: map['numero_contribuable'] as String?,
      adresseSiege: map['adresse_siege'] as String?,
      siteWeb: map['site_web'] as String?,
      description: map['description'] as String?,
      telephoneProfessionnel: map['telephone_professionnel'] as String?,
      emailProfessionnel: map['email_professionnel'] as String?,
      biens: List<String>.from(map['biens'] as List? ?? []),
      documentsJuridiques: List<String>.from(map['documents_juridiques'] as List? ?? []),
      estProfessionnel: map['est_professionnel'] as bool? ?? false,
      statutVerification: map['statut_verification'] as String? ?? 'en_attente',
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Bailleur.fromJson(String source) =>
      Bailleur.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bailleur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
