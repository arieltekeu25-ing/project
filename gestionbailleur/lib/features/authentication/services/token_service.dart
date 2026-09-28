/// Interface du service de gestion des tokens
abstract class TokenService {
  /// Générer un token d'accès
  Future<String> genererAccessToken(Map<String, dynamic> payload);

  /// Générer un token de rafraîchissement
  Future<String> genererRefreshToken(Map<String, dynamic> payload);

  /// Décoder un token
  Map<String, dynamic>? decoderToken(String token);

  /// Vérifier la validité d'un token
  bool verifierValiditeToken(String token);

  /// Récupérer l'expiration d'un token
  DateTime? getExpirationToken(String token);

  /// Stocker le token d'accès
  Future<void> stockerAccessToken(String token);

  /// Stocker le token de rafraîchissement
  Future<void> stockerRefreshToken(String token);

  /// Récupérer le token d'accès stocké
  Future<String?> getAccessToken();

  /// Récupérer le token de rafraîchissement stocké
  Future<String?> getRefreshToken();

  /// Supprimer les tokens stockés
  Future<void> supprimerTokens();
}
