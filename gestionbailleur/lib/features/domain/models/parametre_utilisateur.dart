// Modèle de paramètres utilisateur
class ParametreUtilisateur {
  final String id;
  final String utilisateurId;
  final String langue;
  final String fuseauHoraire;
  final bool notificationsEmail;
  final bool notificationsPush;
  final bool notificationsSms;
  final bool profilPublic;
  final bool localisationPartagee;
  final String? theme;
  final String? frequenceNewsletter;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  ParametreUtilisateur({
    required this.id,
    required this.utilisateurId,
    this.langue = 'fr',
    this.fuseauHoraire = 'UTC',
    this.notificationsEmail = true,
    this.notificationsPush = true,
    this.notificationsSms = false,
    this.profilPublic = false,
    this.localisationPartagee = false,
    this.theme,
    this.frequenceNewsletter,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  ParametreUtilisateur copyWith({
    String? id,
    String? utilisateurId,
    String? langue,
    String? fuseauHoraire,
    bool? notificationsEmail,
    bool? notificationsPush,
    bool? notificationsSms,
    bool? profilPublic,
    bool? localisationPartagee,
    String? theme,
    String? frequenceNewsletter,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return ParametreUtilisateur(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      langue: langue ?? this.langue,
      fuseauHoraire: fuseauHoraire ?? this.fuseauHoraire,
      notificationsEmail: notificationsEmail ?? this.notificationsEmail,
      notificationsPush: notificationsPush ?? this.notificationsPush,
      notificationsSms: notificationsSms ?? this.notificationsSms,
      profilPublic: profilPublic ?? this.profilPublic,
      localisationPartagee: localisationPartagee ?? this.localisationPartagee,
      theme: theme ?? this.theme,
      frequenceNewsletter: frequenceNewsletter ?? this.frequenceNewsletter,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'langue': langue,
      'fuseau_horaire': fuseauHoraire,
      'notifications_email': notificationsEmail,
      'notifications_push': notificationsPush,
      'notifications_sms': notificationsSms,
      'profil_public': profilPublic,
      'localisation_partagee': localisationPartagee,
      'theme': theme,
      'frequence_newsletter': frequenceNewsletter,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory ParametreUtilisateur.fromMap(Map<String, dynamic> map) {
    return ParametreUtilisateur(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      langue: map['langue'] as String? ?? 'fr',
      fuseauHoraire: map['fuseau_horaire'] as String? ?? 'UTC',
      notificationsEmail: map['notifications_email'] as bool? ?? true,
      notificationsPush: map['notifications_push'] as bool? ?? true,
      notificationsSms: map['notifications_sms'] as bool? ?? false,
      profilPublic: map['profil_public'] as bool? ?? false,
      localisationPartagee: map['localisation_partagee'] as bool? ?? false,
      theme: map['theme'] as String?,
      frequenceNewsletter: map['frequence_newsletter'] as String?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory ParametreUtilisateur.fromJson(String source) =>
      ParametreUtilisateur.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParametreUtilisateur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
