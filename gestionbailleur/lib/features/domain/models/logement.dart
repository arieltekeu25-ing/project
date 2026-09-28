// Modèle de logement
class Logement {
  final String id;
  final String titre;
  final String description;
  final double prix;
  final double? caution;
  final double? avance;
  final String devise;
  final double surface;
  final int nombreChambres;
  final int nombreSalons;
  final int nombreCuisines;
  final int nombreSallesDeBain;
  final int nombreToilettes;
  final bool parking;
  final bool balcon;
  final bool terrasse;
  final bool internet;
  final bool climatisation;
  final bool groupeElectrogene;
  final bool forage;
  final bool animauxAutorises;
  final double latitude;
  final double longitude;
  final String adresseId;
  final String bailleurId;
  final String categorieId;
  final String typeId;
  final List<String> equipements;
  final List<String> photos;
  final List<String> videos;
  final int nombreVues;
  final int nombreFavoris;
  final int nombrePartages;
  final double? distance;
  final String statut;
  final DateTime datePublication;
  final DateTime? dateExpiration;
  final DateTime dateCreation;
  final DateTime dateModification;

  Logement({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    this.caution,
    this.avance,
    required this.devise,
    required this.surface,
    required this.nombreChambres,
    required this.nombreSalons,
    required this.nombreCuisines,
    required this.nombreSallesDeBain,
    required this.nombreToilettes,
    this.parking = false,
    this.balcon = false,
    this.terrasse = false,
    this.internet = false,
    this.climatisation = false,
    this.groupeElectrogene = false,
    this.forage = false,
    this.animauxAutorises = false,
    required this.latitude,
    required this.longitude,
    required this.adresseId,
    required this.bailleurId,
    required this.categorieId,
    required this.typeId,
    this.equipements = const [],
    this.photos = const [],
    this.videos = const [],
    this.nombreVues = 0,
    this.nombreFavoris = 0,
    this.nombrePartages = 0,
    this.distance,
    required this.statut,
    required this.datePublication,
    this.dateExpiration,
    required this.dateCreation,
    required this.dateModification,
  });

  Logement copyWith({
    String? id,
    String? titre,
    String? description,
    double? prix,
    double? caution,
    double? avance,
    String? devise,
    double? surface,
    int? nombreChambres,
    int? nombreSalons,
    int? nombreCuisines,
    int? nombreSallesDeBain,
    int? nombreToilettes,
    bool? parking,
    bool? balcon,
    bool? terrasse,
    bool? internet,
    bool? climatisation,
    bool? groupeElectrogene,
    bool? forage,
    bool? animauxAutorises,
    double? latitude,
    double? longitude,
    String? adresseId,
    String? bailleurId,
    String? categorieId,
    String? typeId,
    List<String>? equipements,
    List<String>? photos,
    List<String>? videos,
    int? nombreVues,
    int? nombreFavoris,
    int? nombrePartages,
    double? distance,
    String? statut,
    DateTime? datePublication,
    DateTime? dateExpiration,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Logement(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      caution: caution ?? this.caution,
      avance: avance ?? this.avance,
      devise: devise ?? this.devise,
      surface: surface ?? this.surface,
      nombreChambres: nombreChambres ?? this.nombreChambres,
      nombreSalons: nombreSalons ?? this.nombreSalons,
      nombreCuisines: nombreCuisines ?? this.nombreCuisines,
      nombreSallesDeBain: nombreSallesDeBain ?? this.nombreSallesDeBain,
      nombreToilettes: nombreToilettes ?? this.nombreToilettes,
      parking: parking ?? this.parking,
      balcon: balcon ?? this.balcon,
      terrasse: terrasse ?? this.terrasse,
      internet: internet ?? this.internet,
      climatisation: climatisation ?? this.climatisation,
      groupeElectrogene: groupeElectrogene ?? this.groupeElectrogene,
      forage: forage ?? this.forage,
      animauxAutorises: animauxAutorises ?? this.animauxAutorises,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      adresseId: adresseId ?? this.adresseId,
      bailleurId: bailleurId ?? this.bailleurId,
      categorieId: categorieId ?? this.categorieId,
      typeId: typeId ?? this.typeId,
      equipements: equipements ?? this.equipements,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      nombreVues: nombreVues ?? this.nombreVues,
      nombreFavoris: nombreFavoris ?? this.nombreFavoris,
      nombrePartages: nombrePartages ?? this.nombrePartages,
      distance: distance ?? this.distance,
      statut: statut ?? this.statut,
      datePublication: datePublication ?? this.datePublication,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'caution': caution,
      'avance': avance,
      'devise': devise,
      'surface': surface,
      'nombre_chambres': nombreChambres,
      'nombre_salons': nombreSalons,
      'nombre_cuisines': nombreCuisines,
      'nombre_salles_de_bain': nombreSallesDeBain,
      'nombre_toilettes': nombreToilettes,
      'parking': parking,
      'balcon': balcon,
      'terrasse': terrasse,
      'internet': internet,
      'climatisation': climatisation,
      'groupe_electrogene': groupeElectrogene,
      'forage': forage,
      'animaux_autorises': animauxAutorises,
      'latitude': latitude,
      'longitude': longitude,
      'adresse_id': adresseId,
      'bailleur_id': bailleurId,
      'categorie_id': categorieId,
      'type_id': typeId,
      'equipements': equipements,
      'photos': photos,
      'videos': videos,
      'nombre_vues': nombreVues,
      'nombre_favoris': nombreFavoris,
      'nombre_partages': nombrePartages,
      'distance': distance,
      'statut': statut,
      'date_publication': datePublication.toIso8601String(),
      'date_expiration': dateExpiration?.toIso8601String(),
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Logement.fromMap(Map<String, dynamic> map) {
    return Logement(
      id: map['id'] as String,
      titre: map['titre'] as String,
      description: map['description'] as String,
      prix: map['prix'] as double,
      caution: (map['caution'] as num?)?.toDouble(),
      avance: (map['avance'] as num?)?.toDouble(),
      devise: map['devise'] as String,
      surface: map['surface'] as double,
      nombreChambres: map['nombre_chambres'] as int,
      nombreSalons: map['nombre_salons'] as int,
      nombreCuisines: map['nombre_cuisines'] as int,
      nombreSallesDeBain: map['nombre_salles_de_bain'] as int,
      nombreToilettes: map['nombre_toilettes'] as int,
      parking: map['parking'] as bool? ?? false,
      balcon: map['balcon'] as bool? ?? false,
      terrasse: map['terrasse'] as bool? ?? false,
      internet: map['internet'] as bool? ?? false,
      climatisation: map['climatisation'] as bool? ?? false,
      groupeElectrogene: map['groupe_electrogene'] as bool? ?? false,
      forage: map['forage'] as bool? ?? false,
      animauxAutorises: map['animaux_autorises'] as bool? ?? false,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      adresseId: map['adresse_id'] as String,
      bailleurId: map['bailleur_id'] as String,
      categorieId: map['categorie_id'] as String,
      typeId: map['type_id'] as String,
      equipements: List<String>.from(map['equipements'] as List? ?? []),
      photos: List<String>.from(map['photos'] as List? ?? []),
      videos: List<String>.from(map['videos'] as List? ?? []),
      nombreVues: map['nombre_vues'] as int? ?? 0,
      nombreFavoris: map['nombre_favoris'] as int? ?? 0,
      nombrePartages: map['nombre_partages'] as int? ?? 0,
      distance: (map['distance'] as num?)?.toDouble(),
      statut: map['statut'] as String,
      datePublication: DateTime.parse(map['date_publication'] as String),
      dateExpiration: map['date_expiration'] != null
          ? DateTime.parse(map['date_expiration'] as String)
          : null,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Logement.fromJson(String source) =>
      Logement.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Logement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
