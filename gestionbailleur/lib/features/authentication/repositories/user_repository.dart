import '../models/utilisateur_model.dart';
import '../models/client_model.dart';
import '../models/bailleur_model.dart';
import '../models/administrateur_model.dart';

/// Interface du repository des utilisateurs
abstract class UserRepository {
  /// Récupérer un utilisateur par son ID
  Future<UtilisateurModel?> getUtilisateurById(String id);

  /// Récupérer un utilisateur par son email
  Future<UtilisateurModel?> getUtilisateurByEmail(String email);

  /// Récupérer un utilisateur par son téléphone
  Future<UtilisateurModel?> getUtilisateurByTelephone(String telephone);

  /// Créer un utilisateur
  Future<UtilisateurModel> creerUtilisateur(UtilisateurModel utilisateur);

  /// Mettre à jour un utilisateur
  Future<UtilisateurModel> mettreAJourUtilisateur(UtilisateurModel utilisateur);

  /// Supprimer un utilisateur
  Future<void> supprimerUtilisateur(String id);

  /// Récupérer un client par son ID
  Future<ClientModel?> getClientById(String id);

  /// Créer un client
  Future<ClientModel> creerClient(ClientModel client);

  /// Mettre à jour un client
  Future<ClientModel> mettreAJourClient(ClientModel client);

  /// Récupérer un bailleur par son ID
  Future<BailleurModel?> getBailleurById(String id);

  /// Créer un bailleur
  Future<BailleurModel> creerBailleur(BailleurModel bailleur);

  /// Mettre à jour un bailleur
  Future<BailleurModel> mettreAJourBailleur(BailleurModel bailleur);

  /// Récupérer un administrateur par son ID
  Future<AdministrateurModel?> getAdministrateurById(String id);

  /// Créer un administrateur
  Future<AdministrateurModel> creerAdministrateur(AdministrateurModel administrateur);

  /// Mettre à jour un administrateur
  Future<AdministrateurModel> mettreAJourAdministrateur(AdministrateurModel administrateur);
}
