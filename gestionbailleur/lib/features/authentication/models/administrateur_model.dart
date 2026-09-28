import 'utilisateur_model.dart';
import 'enums/sexe.dart';
import 'enums/langue.dart';
import 'enums/role_utilisateur.dart';
import 'enums/statut_compte.dart';
import 'enums/type_connexion.dart';

/// Modèle spécifique pour un administrateur système
class AdministrateurModel extends UtilisateurModel {
  final List<String> permissions;
  final DateTime? dateExpirationMandat;
  final String? superieurId;
  final bool estSuperAdmin;

  AdministrateurModel({
    required super.id,
    required super.email,
    super.telephone,
    required super.nom,
    required super.prenom,
    super.sexe,
    required super.dateNaissance,
    super.photoUrl,
    super.biographie,
    super.profession,
    super.nationalite,
    super.languePreferee,
    required super.role,
    required super.statut,
    required super.typeConnexion,
    required super.dateCreation,
    super.derniereConnexion,
    super.estVerifie,
    this.permissions = const [],
    this.dateExpirationMandat,
    this.superieurId,
    this.estSuperAdmin = false,
  });

  @override
  AdministrateurModel copyWith({
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
    List<String>? permissions,
    DateTime? dateExpirationMandat,
    String? superieurId,
    bool? estSuperAdmin,
  }) {
    return AdministrateurModel(
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
      permissions: permissions ?? this.permissions,
      dateExpirationMandat: dateExpirationMandat ?? this.dateExpirationMandat,
      superieurId: superieurId ?? this.superieurId,
      estSuperAdmin: estSuperAdmin ?? this.estSuperAdmin,
    );
  }
}
