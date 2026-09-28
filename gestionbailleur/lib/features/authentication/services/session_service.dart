import '../models/session_utilisateur_model.dart';

/// Interface du service de gestion de session
abstract class SessionService {
  /// Créer une nouvelle session
  Future<SessionUtilisateurModel> creerSession({
    required String utilisateurId,
    required String accessToken,
    String? refreshToken,
  });

  /// Récupérer la session active
  Future<SessionUtilisateurModel?> getSessionActive();

  /// Mettre à jour la session
  Future<void> mettreAJourSession(SessionUtilisateurModel session);

  /// Terminer la session active
  Future<void> terminerSession();

  /// Vérifier si une session est active
  Future<bool> estSessionActive();

  /// Nettoyer les sessions expirées
  Future<void> nettoyerSessionsExpirees();
}
