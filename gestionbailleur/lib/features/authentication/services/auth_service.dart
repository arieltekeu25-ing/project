import '../models/utilisateur_model.dart';
import '../models/session_utilisateur_model.dart';
import '../models/enums/type_connexion.dart';

/// Interface du service d'authentification
abstract class AuthService {
  /// Connexion d'un utilisateur
  Future<SessionUtilisateurModel> connexion({
    required String identifiant,
    required String motDePasse,
    TypeConnexion typeConnexion = TypeConnexion.emailMotDePasse,
  });

  /// Inscription d'un nouvel utilisateur
  Future<UtilisateurModel> inscription({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  });

  /// Déconnexion de l'utilisateur
  Future<void> deconnexion();

  /// Réinitialisation du mot de passe
  Future<void> reinitialiserMotDePasse(String email);

  /// Vérification de l'email avec code OTP
  Future<bool> verifierEmail(String email, String codeOtp);

  /// Envoi du code OTP par email
  Future<void> envoyerCodeOtp(String email);

  /// Rafraîchissement du token d'accès
  Future<String> rafraichirToken(String refreshToken);

  /// Vérification de la validité du token
  Future<bool> verifierToken(String token);
}
