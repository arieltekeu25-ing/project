import '../models/utilisateur_model.dart';
import '../models/session_utilisateur_model.dart';
import '../models/enums/type_connexion.dart';

/// Interface du repository d'authentification
abstract class AuthRepository {
  /// Connexion d'un utilisateur
  Future<SessionUtilisateurModel> connexion({
    required String identifiant,
    required String motDePasse,
    TypeConnexion typeConnexion = TypeConnexion.emailMotDePasse,
  });

  /// Inscription d'un client
  Future<UtilisateurModel> inscription({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  });

  /// Inscription d'un bailleur
  Future<UtilisateurModel> inscriptionBailleur({
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

  /// Réinitialiser le mot de passe avec un token
  Future<void> resetPassword({
    required String token,
    required String nouveauMotDePasse,
  });

  /// Vérification de l'email avec code OTP
  Future<bool> verifierEmail(String email, String codeOtp);

  /// Envoi du code OTP par email
  Future<void> envoyerCodeOtp(String email);

  /// Rafraîchissement du token d'accès
  Future<String> rafraichirToken(String refreshToken);

  /// Vérification de la validité du token
  Future<bool> verifierToken(String token);

  /// Obtenir le profil utilisateur
  Future<UtilisateurModel> getProfil();

  /// Mettre à jour le profil utilisateur
  Future<UtilisateurModel> updateProfil(Map<String, dynamic> data);

  /// Changer le mot de passe
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });
}
