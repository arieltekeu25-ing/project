// Modèle de profil utilisateur
class Profil {
  final String id;
  final String utilisateurId;
  final String? bio;
  final String? siteWeb;
  final String? linkedin;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? preferences;
  final String? centreInterets;
  final bool profilPublic;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Profil({
    required this.id,
    required this.utilisateurId,
    this.bio,
    this.siteWeb,
    this.linkedin,
    this.facebook,
    this.twitter,
    this.instagram,
    this.preferences,
    this.centreInterets,
    this.profilPublic = false,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Profil copyWith({
    String? id,
    String? utilisateurId,
    String? bio,
    String? siteWeb,
    String? linkedin,
    String? facebook,
    String? twitter,
    String? instagram,
    String? preferences,
    String? centreInterets,
    bool? profilPublic,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Profil(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      bio: bio ?? this.bio,
      siteWeb: siteWeb ?? this.siteWeb,
      linkedin: linkedin ?? this.linkedin,
      facebook: facebook ?? this.facebook,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      preferences: preferences ?? this.preferences,
      centreInterets: centreInterets ?? this.centreInterets,
      profilPublic: profilPublic ?? this.profilPublic,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'bio': bio,
      'site_web': siteWeb,
      'linkedin': linkedin,
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'preferences': preferences,
      'centre_interets': centreInterets,
      'profil_public': profilPublic,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Profil.fromMap(Map<String, dynamic> map) {
    return Profil(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      bio: map['bio'] as String?,
      siteWeb: map['site_web'] as String?,
      linkedin: map['linkedin'] as String?,
      facebook: map['facebook'] as String?,
      twitter: map['twitter'] as String?,
      instagram: map['instagram'] as String?,
      preferences: map['preferences'] as String?,
      centreInterets: map['centre_interets'] as String?,
      profilPublic: map['profil_public'] as bool? ?? false,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Profil.fromJson(String source) =>
      Profil.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profil && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
