// Modèle de base pour un utilisateur du système
class Utilisateur {
  final String id;
  final String email;
  final String? telephone;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final DateTime dateNaissance;
  final String? sexe;
  final String? nationalite;
  final String? languePreferee;
  final String role;
  final String statut;
  final bool estVerifie;
  final bool estActif;
  final DateTime dateCreation;
  final DateTime dateModification;
  final DateTime? derniereConnexion;

  Utilisateur({
    required this.id,
    required this.email,
    this.telephone,
    required this.nom,
    required this.prenom,
    this.photoUrl,
    required this.dateNaissance,
    this.sexe,
    this.nationalite,
    this.languePreferee,
    required this.role,
    required this.statut,
    this.estVerifie = false,
    this.estActif = true,
    required this.dateCreation,
    required this.dateModification,
    this.derniereConnexion,
  });

  Utilisateur copyWith({
    String? id,
    String? email,
    String? telephone,
    String? nom,
    String? prenom,
    String? photoUrl,
    DateTime? dateNaissance,
    String? sexe,
    String? nationalite,
    String? languePreferee,
    String? role,
    String? statut,
    bool? estVerifie,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? derniereConnexion,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      photoUrl: photoUrl ?? this.photoUrl,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      sexe: sexe ?? this.sexe,
      nationalite: nationalite ?? this.nationalite,
      languePreferee: languePreferee ?? this.languePreferee,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      estVerifie: estVerifie ?? this.estVerifie,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'photo_url': photoUrl,
      'date_naissance': dateNaissance.toIso8601String(),
      'sexe': sexe,
      'nationalite': nationalite,
      'langue_preferee': languePreferee,
      'role': role,
      'statut': statut,
      'est_verifie': estVerifie,
      'est_actif': estActif,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'derniere_connexion': derniereConnexion?.toIso8601String(),
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] as String,
      email: map['email'] as String,
      telephone: map['telephone'] as String?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      photoUrl: map['photo_url'] as String?,
      dateNaissance: DateTime.parse(map['date_naissance'] as String),
      sexe: map['sexe'] as String?,
      nationalite: map['nationalite'] as String?,
      languePreferee: map['langue_preferee'] as String?,
      role: map['role'] as String,
      statut: map['statut'] as String,
      estVerifie: map['est_verifie'] as bool? ?? false,
      estActif: map['est_actif'] as bool? ?? true,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
      derniereConnexion: map['derniere_connexion'] != null
          ? DateTime.parse(map['derniere_connexion'] as String)
          : null,
    );
  }

  String toJson() => toMap().toString();

  factory Utilisateur.fromJson(String source) =>
      Utilisateur.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Utilisateur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
