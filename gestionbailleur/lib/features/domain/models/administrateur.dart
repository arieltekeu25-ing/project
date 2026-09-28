// Modèle d'administrateur système
class Administrateur {
  final String id;
  final String utilisateurId;
  final List<String> permissions;
  final DateTime? dateExpirationMandat;
  final String? superieurId;
  final bool estSuperAdmin;
  final String departement;
  final String? fonction;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Administrateur({
    required this.id,
    required this.utilisateurId,
    this.permissions = const [],
    this.dateExpirationMandat,
    this.superieurId,
    this.estSuperAdmin = false,
    required this.departement,
    this.fonction,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Administrateur copyWith({
    String? id,
    String? utilisateurId,
    List<String>? permissions,
    DateTime? dateExpirationMandat,
    String? superieurId,
    bool? estSuperAdmin,
    String? departement,
    String? fonction,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Administrateur(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      permissions: permissions ?? this.permissions,
      dateExpirationMandat: dateExpirationMandat ?? this.dateExpirationMandat,
      superieurId: superieurId ?? this.superieurId,
      estSuperAdmin: estSuperAdmin ?? this.estSuperAdmin,
      departement: departement ?? this.departement,
      fonction: fonction ?? this.fonction,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'permissions': permissions,
      'date_expiration_mandat': dateExpirationMandat?.toIso8601String(),
      'superieur_id': superieurId,
      'est_super_admin': estSuperAdmin,
      'departement': departement,
      'fonction': fonction,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Administrateur.fromMap(Map<String, dynamic> map) {
    return Administrateur(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      permissions: List<String>.from(map['permissions'] as List? ?? []),
      dateExpirationMandat: map['date_expiration_mandat'] != null
          ? DateTime.parse(map['date_expiration_mandat'] as String)
          : null,
      superieurId: map['superieur_id'] as String?,
      estSuperAdmin: map['est_super_admin'] as bool? ?? false,
      departement: map['departement'] as String,
      fonction: map['fonction'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Administrateur.fromJson(String source) =>
      Administrateur.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Administrateur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
