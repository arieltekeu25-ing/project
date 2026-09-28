// Modèle de client (locataire)
class Client {
  final String id;
  final String utilisateurId;
  final String? numeroPieceIdentite;
  final String? typePieceIdentite;
  final String? profession;
  final String? revenuMensuel;
  final String? employeur;
  final String? adresseTravail;
  final String? telephoneTravail;
  final String? garantNom;
  final String? garantTelephone;
  final String? garantAdresse;
  final List<String> documents;
  final String statutVerification;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Client({
    required this.id,
    required this.utilisateurId,
    this.numeroPieceIdentite,
    this.typePieceIdentite,
    this.profession,
    this.revenuMensuel,
    this.employeur,
    this.adresseTravail,
    this.telephoneTravail,
    this.garantNom,
    this.garantTelephone,
    this.garantAdresse,
    this.documents = const [],
    this.statutVerification = 'en_attente',
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Client copyWith({
    String? id,
    String? utilisateurId,
    String? numeroPieceIdentite,
    String? typePieceIdentite,
    String? profession,
    String? revenuMensuel,
    String? employeur,
    String? adresseTravail,
    String? telephoneTravail,
    String? garantNom,
    String? garantTelephone,
    String? garantAdresse,
    List<String>? documents,
    String? statutVerification,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Client(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      numeroPieceIdentite: numeroPieceIdentite ?? this.numeroPieceIdentite,
      typePieceIdentite: typePieceIdentite ?? this.typePieceIdentite,
      profession: profession ?? this.profession,
      revenuMensuel: revenuMensuel ?? this.revenuMensuel,
      employeur: employeur ?? this.employeur,
      adresseTravail: adresseTravail ?? this.adresseTravail,
      telephoneTravail: telephoneTravail ?? this.telephoneTravail,
      garantNom: garantNom ?? this.garantNom,
      garantTelephone: garantTelephone ?? this.garantTelephone,
      garantAdresse: garantAdresse ?? this.garantAdresse,
      documents: documents ?? this.documents,
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
      'numero_piece_identite': numeroPieceIdentite,
      'type_piece_identite': typePieceIdentite,
      'profession': profession,
      'revenu_mensuel': revenuMensuel,
      'employeur': employeur,
      'adresse_travail': adresseTravail,
      'telephone_travail': telephoneTravail,
      'garant_nom': garantNom,
      'garant_telephone': garantTelephone,
      'garant_adresse': garantAdresse,
      'documents': documents,
      'statut_verification': statutVerification,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      numeroPieceIdentite: map['numero_piece_identite'] as String?,
      typePieceIdentite: map['type_piece_identite'] as String?,
      profession: map['profession'] as String?,
      revenuMensuel: map['revenu_mensuel'] as String?,
      employeur: map['employeur'] as String?,
      adresseTravail: map['adresse_travail'] as String?,
      telephoneTravail: map['telephone_travail'] as String?,
      garantNom: map['garant_nom'] as String?,
      garantTelephone: map['garant_telephone'] as String?,
      garantAdresse: map['garant_adresse'] as String?,
      documents: List<String>.from(map['documents'] as List? ?? []),
      statutVerification: map['statut_verification'] as String? ?? 'en_attente',
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Client.fromJson(String source) =>
      Client.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
