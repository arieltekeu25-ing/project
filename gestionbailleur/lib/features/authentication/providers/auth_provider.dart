import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/etat_authentification.dart';
import '../models/session_utilisateur_model.dart';
import '../repositories/auth_repository_impl.dart';
import '../models/enums/role_utilisateur.dart';
import 'package:gestionbailleur/core/services/secure_storage_service.dart';
import 'package:gestionbailleur/core/providers/theme_provider.dart';
import 'package:gestionbailleur/core/constants/app_constants.dart';

/// Provider pour le repository d'authentification
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl();
});

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, EtatAuthentification>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider), ref),
);

/// Notifier pour la gestion de l'état d'authentification
class AuthNotifier extends StateNotifier<EtatAuthentification> {
  final AuthRepositoryImpl _repository;
  final SecureStorageService _secureStorage = SecureStorageService.instance;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(EtatAuthentification.initial()) {
    _checkAuthStatus();
  }

  /// Vérifier le statut d'authentification au démarrage
  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await _secureStorage.isAuthenticated();
    if (isAuthenticated) {
      try {
        final utilisateur = await _repository.getProfil();
        state = EtatAuthentification.authentifie(
          utilisateur: utilisateur,
          session: SessionUtilisateurModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            utilisateurId: utilisateur.id,
            tokenAccessToken: await _secureStorage.getAccessToken() ?? '',
            tokenRefreshToken: await _secureStorage.getRefreshToken(),
            dateDebut: DateTime.now(),
            estActive: true,
          ),
        );
        // Charger le thème utilisateur
        _ref.read(themeProvider.notifier).ensureThemeLoaded();
      } catch (e) {
        await _secureStorage.clearTokens();
        state = EtatAuthentification.nonAuthentifie();
      }
    }
  }

  /// Rafraîchir le profil utilisateur (pour mettre à jour le statut après validation admin)
  Future<void> refreshProfile() async {
    if (state case EtatAuthentificationAuthentifie(:final session)) {
      if (session != null) {
        try {
          final utilisateur = await _repository.getProfil();
          state = EtatAuthentification.authentifie(
            utilisateur: utilisateur,
            session: session,
          );
        } catch (e) {
          // Erreur silencieuse - ne pas déconnecter l'utilisateur
        }
      }
    }
  }

  /// Connexion de l'utilisateur
  Future<void> connexion({
    required String identifiant,
    required String motDePasse,
  }) async {
    state = EtatAuthentification.chargement(message: 'Connexion en cours...');
    try {
      final session = await _repository.connexion(
        identifiant: identifiant,
        motDePasse: motDePasse,
      );
      final utilisateur = await _repository.getProfil();
      state = EtatAuthentification.authentifie(
        utilisateur: utilisateur,
        session: session,
      );
      // Charger le thème utilisateur après connexion
      _ref.read(themeProvider.notifier).ensureThemeLoaded();
    } catch (e) {
      String errorMessage = _parseLoginError(e.toString());
      state = EtatAuthentification.erreur(
        message: errorMessage,
        code: 'LOGIN_ERROR',
      );
    }
  }

  /// Parser les erreurs de connexion pour afficher des messages spécifiques
  String _parseLoginError(String error) {
    if (error.contains('Aucun compte trouvé')) {
      return 'Aucun compte trouvé avec cet email. Veuillez créer un compte.';
    }
    if (error.contains('Mot de passe incorrect')) {
      return 'Mot de passe incorrect. Veuillez réessayer.';
    }
    if (error.contains('bloqué par l\'administrateur')) {
      return 'Votre compte a été bloqué par l\'administrateur. Veuillez le contacter pour plus d\'informations.';
    }
    if (error.contains('suspendu temporairement')) {
      return 'Votre compte est suspendu temporairement. Veuillez contacter l\'administrateur.';
    }
    // Ne plus bloquer les bailleurs en attente de validation - ils peuvent se connecter
    return 'Erreur de connexion. Veuillez vérifier vos identifiants et réessayer.';
  }

  /// Inscription d'un client
  Future<void> inscriptionClient({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    state = EtatAuthentification.chargement(message: 'Création du compte...');
    try {
      final utilisateur = await _repository.inscription(
        email: email,
        motDePasse: motDePasse,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      
      // Ne créer la session que si on a un token d'accès
      if (accessToken != null) {
        final session = SessionUtilisateurModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          utilisateurId: utilisateur.id,
          tokenAccessToken: accessToken,
          tokenRefreshToken: refreshToken,
          dateDebut: DateTime.now(),
          estActive: true,
        );
        state = EtatAuthentification.authentifie(
          utilisateur: utilisateur,
          session: session,
        );
      } else {
        // Si pas de token, rediriger vers login
        state = EtatAuthentification.nonAuthentifie();
      }
    } catch (e) {
      state = EtatAuthentification.erreur(
        message: e.toString(),
        code: 'REGISTER_ERROR',
      );
    }
  }

  /// Inscription d'un bailleur
  Future<void> inscriptionBailleur({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    state = EtatAuthentification.chargement(message: 'Création du compte...');
    try {
      final utilisateur = await _repository.inscriptionBailleur(
        email: email,
        motDePasse: motDePasse,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      
      // Ne créer la session que si on a un token d'accès
      if (accessToken != null) {
        final session = SessionUtilisateurModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          utilisateurId: utilisateur.id,
          tokenAccessToken: accessToken,
          tokenRefreshToken: refreshToken,
          dateDebut: DateTime.now(),
          estActive: true,
        );
        state = EtatAuthentification.authentifie(
          utilisateur: utilisateur,
          session: session,
        );
      } else {
        // Si pas de token, rediriger vers login
        state = EtatAuthentification.nonAuthentifie();
      }
    } catch (e) {
      state = EtatAuthentification.erreur(
        message: e.toString(),
        code: 'REGISTER_ERROR',
      );
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> deconnexion() async {
    state = EtatAuthentification.chargement(message: 'Déconnexion...');
    try {
      await _repository.deconnexion();
      state = EtatAuthentification.nonAuthentifie();
      // Recharger le thème utilisateur après déconnexion pour le conserver
      _ref.read(themeProvider.notifier).ensureThemeLoaded();
    } catch (e) {
      // Continuer même si erreur serveur
      await _secureStorage.clearTokens();
      state = EtatAuthentification.nonAuthentifie();
      // Recharger le thème utilisateur après déconnexion pour le conserver
      _ref.read(themeProvider.notifier).ensureThemeLoaded();
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> reinitialiserMotDePasse(String email) async {
    state = EtatAuthentification.chargement(message: 'Envoi en cours...');
    try {
      await _repository.reinitialiserMotDePasse(email);
      state = EtatAuthentification.initial();
    } catch (e) {
      state = EtatAuthentification.erreur(
        message: e.toString(),
        code: 'FORGOT_PASSWORD_ERROR',
      );
    }
  }

  /// Réinitialiser le mot de passe avec token
  Future<void> resetPassword({
    required String token,
    required String nouveauMotDePasse,
  }) async {
    state = EtatAuthentification.chargement(message: 'Réinitialisation...');
    try {
      await _repository.resetPassword(
        token: token,
        nouveauMotDePasse: nouveauMotDePasse,
      );
      state = EtatAuthentification.initial();
    } catch (e) {
      state = EtatAuthentification.erreur(
        message: e.toString(),
        code: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  /// Rafraîchir le token
  Future<void> rafraichirToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _repository.rafraichirToken(refreshToken);
      } catch (e) {
        await deconnexion();
      }
    }
  }

  /// Obtenir la route de redirection selon le rôle
  String getRouteRedirection() {
    String route = AppConstants.routeHome;
    
    if (state case EtatAuthentificationAuthentifie(:final utilisateur)) {
      if (utilisateur != null) {
        route = switch (utilisateur.role) {
          RoleUtilisateur.client => AppConstants.routeHome,
          RoleUtilisateur.bailleur => AppConstants.routeLandlordDashboard,
          RoleUtilisateur.administrateur => AppConstants.routeAdminDashboard,
        };
      }
    }
    
    return route;
  }

  /// Mettre à jour les informations du profil utilisateur
  Future<void> updateProfile({
    String? nom,
    String? prenom,
    String? biographie,
    String? profession,
    String? nationalite,
  }) async {
    if (state case EtatAuthentificationAuthentifie(:final utilisateur, :final session)) {
      if (utilisateur == null || session == null) return;

      try {
        state = EtatAuthentification.chargement(message: 'Mise à jour du profil...');

        final updatedData = <String, dynamic>{};
        if (nom != null) updatedData['nom'] = nom;
        if (prenom != null) updatedData['prenom'] = prenom;
        if (biographie != null) updatedData['biographie'] = biographie;
        if (profession != null) updatedData['profession'] = profession;
        if (nationalite != null) updatedData['nationalite'] = nationalite;

        // Appeler l'API pour mettre à jour le profil
        await _repository.updateProfile(updatedData);

        // Mettre à jour l'état local
        final updatedUtilisateur = utilisateur.copyWith(
          nom: nom ?? utilisateur.nom,
          prenom: prenom ?? utilisateur.prenom,
          biographie: biographie ?? utilisateur.biographie,
          profession: profession ?? utilisateur.profession,
          nationalite: nationalite ?? utilisateur.nationalite,
        );

        state = EtatAuthentification.authentifie(
          utilisateur: updatedUtilisateur,
          session: session,
        );
      } catch (e) {
        state = EtatAuthentification.authentifie(
          utilisateur: utilisateur,
          session: session,
        );
        rethrow;
      }
    }
  }

  /// Mettre à jour l'URL de photo de profil dans l'état réactif
  void updateProfilePhoto(String? photoUrl) {
    if (state case EtatAuthentificationAuthentifie(:final utilisateur, :final session)) {
      if (utilisateur != null && session != null) {
        final updatedUtilisateur = utilisateur.copyWith(photoUrl: photoUrl);
        state = EtatAuthentification.authentifie(
          utilisateur: updatedUtilisateur,
          session: session,
        );
      }
    }
  }

  /// Réinitialiser l'état
  void resetState() {
    state = EtatAuthentification.initial();
  }
}
