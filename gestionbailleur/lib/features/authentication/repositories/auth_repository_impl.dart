import 'package:gestionbailleur/core/services/api_service.dart';
import 'package:gestionbailleur/core/services/secure_storage_service.dart';
import 'package:gestionbailleur/features/authentication/models/enums/role_utilisateur.dart';
import 'package:gestionbailleur/features/authentication/models/enums/statut_compte.dart';
import 'package:gestionbailleur/features/authentication/models/enums/type_connexion.dart';
import 'package:gestionbailleur/features/authentication/models/session_utilisateur_model.dart';
import 'package:gestionbailleur/features/authentication/models/utilisateur_model.dart';
import 'auth_repository.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService = ApiService.instance;
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  @override
  Future<SessionUtilisateurModel> connexion({
    required String identifiant,
    required String motDePasse,
    TypeConnexion typeConnexion = TypeConnexion.emailMotDePasse,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/auth/login/',
        body: {
          'identifier': identifiant,
          'password': motDePasse,
        },
        requireAuth: false,
      );

      final tokens = response['tokens'] as Map<String, dynamic>;
      final userData = response['user'] as Map<String, dynamic>;

      // Sauvegarder les tokens
      await _secureStorage.setAccessToken(tokens['access_token']);
      await _secureStorage.setRefreshToken(tokens['refresh_token']);
      await _secureStorage.setUserId(userData['id']);

      // Sauvegarder le rôle si présent dans la réponse
      if (userData['role'] != null) {
        final roleData = userData['role'] as Map<String, dynamic>;
        await _secureStorage.setRoleCode(roleData['code']?.toString() ?? '');
      }

      return SessionUtilisateurModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        utilisateurId: userData['id'],
        tokenAccessToken: tokens['access_token'],
        tokenRefreshToken: tokens['refresh_token'],
        dateDebut: DateTime.now(),
        estActive: true,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UtilisateurModel> inscription({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    try {
      final body = {
        'email': email,
        'telephone': telephone ?? '',
        'password': motDePasse,
        'password_confirm': motDePasse,
        'user_type': 'client', // Par défaut, sera modifié selon le choix
        'nom': nom,
        'prenom': prenom,
      };
      
      final response = await _apiService.post(
        '/api/v1/auth/register/',
        body: body,
        requireAuth: false,
      );

      final userData = response['user'] as Map<String, dynamic>;
      final tokens = response['tokens'] as Map<String, dynamic>?;

      // Sauvegarder les tokens si présents
      if (tokens != null) {
        final accessToken = tokens['access_token'] as String?;
        final refreshToken = tokens['refresh_token'] as String?;
        if (accessToken != null) {
          await _secureStorage.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _secureStorage.setRefreshToken(refreshToken);
        }
      }
      if (userData['id'] != null) {
        await _secureStorage.setUserId(userData['id'].toString());
      }

      return _mapUserFromApi(userData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UtilisateurModel> inscriptionBailleur({
    required String email,
    required String motDePasse,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    try {
      final body = {
        'email': email,
        'telephone': telephone ?? '',
        'password': motDePasse,
        'password_confirm': motDePasse,
        'user_type': 'landlord',
        'nom': nom,
        'prenom': prenom,
      };
      
      final response = await _apiService.post(
        '/api/v1/auth/register/',
        body: body,
        requireAuth: false,
      );

      final userData = response['user'] as Map<String, dynamic>;
      final tokens = response['tokens'] as Map<String, dynamic>?;

      // Sauvegarder les tokens si présents
      if (tokens != null) {
        final accessToken = tokens['access_token'] as String?;
        final refreshToken = tokens['refresh_token'] as String?;
        if (accessToken != null) {
          await _secureStorage.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _secureStorage.setRefreshToken(refreshToken);
        }
      }
      if (userData['id'] != null) {
        await _secureStorage.setUserId(userData['id'].toString());
      }

      return _mapUserFromApi(userData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deconnexion() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiService.post(
          '/api/v1/auth/logout/',
          body: {'refresh_token': refreshToken},
          requireAuth: true,
        );
      }
    } catch (e) {
      // Continuer même si la déconnexion échoue côté serveur
    } finally {
      // Toujours supprimer les tokens localement
      await _secureStorage.clearTokens();
    }
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _apiService.post(
        '/api/v1/auth/forgot-password/',
        body: {'email': email},
        requireAuth: false,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String nouveauMotDePasse,
  }) async {
    try {
      await _apiService.post(
        '/api/v1/auth/reset-password/',
        body: {
          'token': token,
          'new_password': nouveauMotDePasse,
          'new_password_confirm': nouveauMotDePasse,
        },
        requireAuth: false,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> verifierEmail(String email, String codeOtp) async {
    // TODO: Implémenter quand l'API sera disponible
    return true;
  }

  @override
  Future<void> envoyerCodeOtp(String email) async {
    // TODO: Implémenter quand l'API sera disponible
  }

  @override
  Future<String> rafraichirToken(String refreshToken) async {
    try {
      final response = await _apiService.post(
        '/api/v1/auth/refresh/',
        body: {'refresh': refreshToken},
        requireAuth: false,
      );

      final newAccessToken = response['access'] as String;
      final newRefreshToken = response['refresh'] as String;

      await _secureStorage.setAccessToken(newAccessToken);
      await _secureStorage.setRefreshToken(newRefreshToken);

      return newAccessToken;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> verifierToken(String token) async {
    try {
      await _apiService.get('/api/v1/auth/me/', requireAuth: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UtilisateurModel> getProfil() async {
    try {
      // Récupérer le rôle stocké lors de la connexion
      final storedRoleCode = await _secureStorage.getRoleCode();
      
      // Essayer d'abord le endpoint /api/v1/profiles/me/ qui contient la photo
      try {
        final response = await _apiService.get('/api/v1/profiles/me/');
        
        // Si /profiles/me/ ne contient pas de rôle, utiliser celui stocké
        if (response['role'] == null && storedRoleCode != null && storedRoleCode.isNotEmpty) {
          response['role'] = storedRoleCode;
        }
        
        return _mapUserFromProfileApi(response);
      } catch (e) {
        // Fallback sur /api/v1/auth/me/ si /profiles/me/ échoue
        final response = await _apiService.get('/api/v1/auth/me/');
        
        // Si /auth/me/ ne contient pas de rôle, utiliser celui stocké
        if (response['role'] == null && storedRoleCode != null && storedRoleCode.isNotEmpty) {
          response['role'] = storedRoleCode;
        }
        
        return _mapUserFromApi(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mapper les données de l'API profile vers le modèle utilisateur
  UtilisateurModel _mapUserFromProfileApi(Map<String, dynamic> data) {
    final roleRaw = data['role'];
    final mappedRole = _mapRoleFromApi(roleRaw);
    
    return UtilisateurModel(
      id: data['id']?.toString() ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      dateNaissance: DateTime.now(),
      photoUrl: data['photo'],
      role: mappedRole,
      statut: _mapStatutFromApi(data['etat_compte'] ?? 'actif'),
      typeConnexion: TypeConnexion.emailMotDePasse,
      dateCreation: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      derniereConnexion: data['derniere_connexion'] != null
          ? DateTime.parse(data['derniere_connexion'])
          : null,
      estVerifie: data['email_verifie'] ?? false,
    );
  }

  @override
  Future<UtilisateurModel> updateProfil(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        '/api/v1/auth/profile/',
        body: data,
        requireAuth: true,
      );
      return _mapUserFromApi(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      await _apiService.post(
        '/api/v1/auth/change-password/',
        body: {
          'old_password': ancienMotDePasse,
          'new_password': nouveauMotDePasse,
          'new_password_confirm': nouveauMotDePasse,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mapper les données de l'API vers le modèle utilisateur
  UtilisateurModel _mapUserFromApi(Map<String, dynamic> data) {
    final roleRaw = data['role'];
    final mappedRole = _mapRoleFromApi(roleRaw);
    
    return UtilisateurModel(
      id: data['id']?.toString() ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      dateNaissance: data['date_naissance'] != null
          ? DateTime.parse(data['date_naissance'])
          : DateTime.now(),
      photoUrl: data['photo'],
      role: mappedRole,
      statut: _mapStatutFromApi(data['etat_compte']),
      typeConnexion: TypeConnexion.emailMotDePasse,
      dateCreation: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      derniereConnexion: data['derniere_connexion'] != null
          ? DateTime.parse(data['derniere_connexion'])
          : null,
      estVerifie: data['email_verifie'] ?? false,
    );
  }

  /// Mapper le rôle depuis l'API
  RoleUtilisateur _mapRoleFromApi(dynamic roleData) {
    if (roleData == null) {
      return RoleUtilisateur.client;
    }
    
    // Handle if role is a dict with 'code' field
    if (roleData is Map) {
      final code = roleData['code']?.toString();
      switch (code?.toLowerCase()) {
        case 'administrateur':
        case 'super_administrateur':
          return RoleUtilisateur.administrateur;
        case 'bailleur':
        case 'landlord':
          return RoleUtilisateur.bailleur;
        case 'client':
        default:
          return RoleUtilisateur.client;
      }
    }
    
    // Handle if role is just a string
    if (roleData is String) {
      switch (roleData.toLowerCase()) {
        case 'administrateur':
        case 'super_administrateur':
          return RoleUtilisateur.administrateur;
        case 'bailleur':
        case 'landlord':
          return RoleUtilisateur.bailleur;
        case 'client':
        default:
          return RoleUtilisateur.client;
      }
    }
    
    return RoleUtilisateur.client;
  }

  /// Mapper le statut depuis l'API
  StatutCompte _mapStatutFromApi(String? etatCompte) {
    switch (etatCompte) {
      case 'ACTIF':
        return StatutCompte.actif;
      case 'EN_ATTENTE':
        return StatutCompte.enAttenteValidation;
      case 'BLOQUE':
        return StatutCompte.bloque;
      case 'INACTIF':
        return StatutCompte.desactive;
      case 'SUSPENDU':
        return StatutCompte.bloque;
      default:
        return StatutCompte.enAttente;
    }
  }

  /// Gérer les erreurs
  dynamic _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/api/v1/profiles/me/', body: data);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      rethrow;
    }
  }
}
