import 'enums/role_utilisateur.dart';
import 'enums/sexe.dart';
import 'enums/langue.dart';
import 'enums/statut_compte.dart';
import 'enums/type_connexion.dart';

/// Modèle de base pour un utilisateur du système
class UtilisateurModel {
  final String id;
  final String email;
  final String? telephone;
  final String nom;
  final String prenom;
  final Sexe? sexe;
  final DateTime dateNaissance;
  final String? photoUrl;
  final String? biographie;
  final String? profession;
  final String? nationalite;
  final Langue languePreferee;
  final RoleUtilisateur role;
  final StatutCompte statut;
  final TypeConnexion typeConnexion;
  final DateTime dateCreation;
  final DateTime? derniereConnexion;
  final bool estVerifie;

  UtilisateurModel({
    required this.id,
    required this.email,
    this.telephone,
    required this.nom,
    required this.prenom,
    this.sexe,
    required this.dateNaissance,
    this.photoUrl,
    this.biographie,
    this.profession,
    this.nationalite,
    this.languePreferee = Langue.francais,
    required this.role,
    required this.statut,
    required this.typeConnexion,
    required this.dateCreation,
    this.derniereConnexion,
    this.estVerifie = false,
  });

  /// Copie du modèle avec modification de certains champs
  UtilisateurModel copyWith({
    String? id,
    String? email,
    String? telephone,
    String? nom,
    String? prenom,
    Sexe? sexe,
    DateTime? dateNaissance,
    String? photoUrl,
    String? biographie,
    String? profession,
    String? nationalite,
    Langue? languePreferee,
    RoleUtilisateur? role,
    StatutCompte? statut,
    TypeConnexion? typeConnexion,
    DateTime? dateCreation,
    DateTime? derniereConnexion,
    bool? estVerifie,
  }) {
    return UtilisateurModel(
      id: id ?? this.id,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      photoUrl: photoUrl ?? this.photoUrl,
      biographie: biographie ?? this.biographie,
      profession: profession ?? this.profession,
      nationalite: nationalite ?? this.nationalite,
      languePreferee: languePreferee ?? this.languePreferee,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      typeConnexion: typeConnexion ?? this.typeConnexion,
      dateCreation: dateCreation ?? this.dateCreation,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      estVerifie: estVerifie ?? this.estVerifie,
    );
  }
}
