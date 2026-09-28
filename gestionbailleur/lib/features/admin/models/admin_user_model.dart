/// Modèle d'utilisateur pour l'administration
class AdminUserModel {
  final String id;
  final String email;
  final String? telephone;
  final String nom;
  final String prenom;
  final String? photo;
  final String? dateNaissance;
  final String? genre;
  final String langue;
  final String etatCompte;
  final bool emailVerifie;
  final bool telephoneVerifie;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final String? derniereConnexion;
  final String createdAt;
  final String updatedAt;
  final String? role;
  final String? roleCode;
  final bool isLandlord;
  final bool isClient;
  final bool isAdmin;

  AdminUserModel({
    required this.id,
    required this.email,
    this.telephone,
    required this.nom,
    required this.prenom,
    this.photo,
    this.dateNaissance,
    this.genre,
    required this.langue,
    required this.etatCompte,
    required this.emailVerifie,
    required this.telephoneVerifie,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    this.derniereConnexion,
    required this.createdAt,
    required this.updatedAt,
    this.role,
    this.roleCode,
    required this.isLandlord,
    required this.isClient,
    required this.isAdmin,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      photo: json['photo'],
      dateNaissance: json['date_naissance'],
      genre: json['genre'],
      langue: json['langue'] ?? 'fr',
      etatCompte: json['etat_compte'] ?? 'INACTIF',
      emailVerifie: json['email_verifie'] ?? false,
      telephoneVerifie: json['telephone_verifie'] ?? false,
      isActive: json['is_active'] ?? false,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      derniereConnexion: json['derniere_connexion'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      role: json['role'],
      roleCode: json['role_code'],
      isLandlord: json['is_landlord'] ?? false,
      isClient: json['is_client'] ?? false,
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'photo': photo,
      'date_naissance': dateNaissance,
      'genre': genre,
      'langue': langue,
      'etat_compte': etatCompte,
      'email_verifie': emailVerifie,
      'telephone_verifie': telephoneVerifie,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'derniere_connexion': derniereConnexion,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'role_code': roleCode,
      'is_landlord': isLandlord,
      'is_client': isClient,
      'is_admin': isAdmin,
    };
  }

  String get nomComplet => '$prenom $nom'.trim();

  String get statutLabel {
    switch (etatCompte) {
      case 'ACTIF':
        return 'Actif';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'BLOQUE':
        return 'Bloqué';
      case 'SUSPENDU':
        return 'Suspendu';
      case 'INACTIF':
        return 'Inactif';
      default:
        return etatCompte;
    }
  }
}
