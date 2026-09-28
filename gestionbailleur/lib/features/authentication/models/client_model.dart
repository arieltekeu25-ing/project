import 'utilisateur_model.dart';
import 'enums/sexe.dart';
import 'enums/langue.dart';
import 'enums/role_utilisateur.dart';
import 'enums/statut_compte.dart';
import 'enums/type_connexion.dart';

/// Modèle spécifique pour un client (locataire)
class ClientModel extends UtilisateurModel {
  final String? numeroPieceIdentite;
  final String? typePieceIdentite;
  final String? revenuMensuel;
  final String? employeur;
  final String? adresseTravail;
  final List<String> documents;

  ClientModel({
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
    this.numeroPieceIdentite,
    this.typePieceIdentite,
    this.revenuMensuel,
    this.employeur,
    this.adresseTravail,
    this.documents = const [],
  });

  @override
  ClientModel copyWith({
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
    String? numeroPieceIdentite,
    String? typePieceIdentite,
    String? revenuMensuel,
    String? employeur,
    String? adresseTravail,
    List<String>? documents,
  }) {
    return ClientModel(
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
      numeroPieceIdentite: numeroPieceIdentite ?? this.numeroPieceIdentite,
      typePieceIdentite: typePieceIdentite ?? this.typePieceIdentite,
      revenuMensuel: revenuMensuel ?? this.revenuMensuel,
      employeur: employeur ?? this.employeur,
      adresseTravail: adresseTravail ?? this.adresseTravail,
      documents: documents ?? this.documents,
    );
  }
}
