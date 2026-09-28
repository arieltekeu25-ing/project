// Modèle de session utilisateur
class SessionUtilisateur {
  final String id;
  final String utilisateurId;
  final String tokenAccessToken;
  final String? tokenRefreshToken;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final String? localisation;
  final bool estActive;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  SessionUtilisateur({
    required this.id,
    required this.utilisateurId,
    required this.tokenAccessToken,
    this.tokenRefreshToken,
    required this.dateDebut,
    this.dateFin,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.localisation,
    this.estActive = true,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  SessionUtilisateur copyWith({
    String? id,
    String? utilisateurId,
    String? tokenAccessToken,
    String? tokenRefreshToken,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    String? localisation,
    bool? estActive,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return SessionUtilisateur(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      tokenAccessToken: tokenAccessToken ?? this.tokenAccessToken,
      tokenRefreshToken: tokenRefreshToken ?? this.tokenRefreshToken,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      localisation: localisation ?? this.localisation,
      estActive: estActive ?? this.estActive,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'token_access_token': tokenAccessToken,
      'token_refresh_token': tokenRefreshToken,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'device_id': deviceId,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'localisation': localisation,
      'est_active': estActive,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory SessionUtilisateur.fromMap(Map<String, dynamic> map) {
    return SessionUtilisateur(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      tokenAccessToken: map['token_access_token'] as String,
      tokenRefreshToken: map['token_refresh_token'] as String?,
      dateDebut: DateTime.parse(map['date_debut'] as String),
      dateFin: map['date_fin'] != null
          ? DateTime.parse(map['date_fin'] as String)
          : null,
      deviceId: map['device_id'] as String?,
      ipAddress: map['ip_address'] as String?,
      userAgent: map['user_agent'] as String?,
      localisation: map['localisation'] as String?,
      estActive: map['est_active'] as bool? ?? true,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory SessionUtilisateur.fromJson(String source) =>
      SessionUtilisateur.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionUtilisateur && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
