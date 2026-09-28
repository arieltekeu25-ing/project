
/// Modèle représentant la session utilisateur active
class SessionUtilisateurModel {
  final String id;
  final String utilisateurId;
  final String tokenAccessToken;
  final String? tokenRefreshToken;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final bool estActive;

  SessionUtilisateurModel({
    required this.id,
    required this.utilisateurId,
    required this.tokenAccessToken,
    this.tokenRefreshToken,
    required this.dateDebut,
    this.dateFin,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.estActive = true,
  });

  /// Vérifie si la session est expirée
  bool estExpiree() {
    if (dateFin == null) return false;
    return DateTime.now().isAfter(dateFin!);
  }

  SessionUtilisateurModel copyWith({
    String? id,
    String? utilisateurId,
    String? tokenAccessToken,
    String? tokenRefreshToken,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    bool? estActive,
  }) {
    return SessionUtilisateurModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      tokenAccessToken: tokenAccessToken ?? this.tokenAccessToken,
      tokenRefreshToken: tokenRefreshToken ?? this.tokenRefreshToken,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      estActive: estActive ?? this.estActive,
    );
  }
}
