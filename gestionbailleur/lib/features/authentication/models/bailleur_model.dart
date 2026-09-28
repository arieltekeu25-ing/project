import 'utilisateur_model.dart';
import 'enums/sexe.dart';
import 'enums/langue.dart';
import 'enums/role_utilisateur.dart';
import 'enums/statut_compte.dart';
import 'enums/type_connexion.dart';

/// Modèle spécifique pour un bailleur (propriétaire)
class BailleurModel extends UtilisateurModel {
  final String? raisonSociale;
  final String? numeroRegistreCommerce;
  final String? numeroContribuable;
  final String? adresseSiege;
  final String? siteWeb;
  final String? description;
  final List<String> biens;
  final List<String> documentsJuridiques;
  final bool estProfessionnel;

  BailleurModel({
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
    this.raisonSociale,
    this.numeroRegistreCommerce,
    this.numeroContribuable,
    this.adresseSiege,
    this.siteWeb,
    this.description,
    this.biens = const [],
    this.documentsJuridiques = const [],
    this.estProfessionnel = false,
  });

  @override
  BailleurModel copyWith({
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
    String? raisonSociale,
    String? numeroRegistreCommerce,
    String? numeroContribuable,
    String? adresseSiege,
    String? siteWeb,
    String? description,
    List<String>? biens,
    List<String>? documentsJuridiques,
    bool? estProfessionnel,
  }) {
    return BailleurModel(
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
      raisonSociale: raisonSociale ?? this.raisonSociale,
      numeroRegistreCommerce: numeroRegistreCommerce ?? this.numeroRegistreCommerce,
      numeroContribuable: numeroContribuable ?? this.numeroContribuable,
      adresseSiege: adresseSiege ?? this.adresseSiege,
      siteWeb: siteWeb ?? this.siteWeb,
      description: description ?? this.description,
      biens: biens ?? this.biens,
      documentsJuridiques: documentsJuridiques ?? this.documentsJuridiques,
      estProfessionnel: estProfessionnel ?? this.estProfessionnel,
    );
  }
}
