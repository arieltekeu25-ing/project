// Modèle de recherche enregistrée
class RechercheEnregistree {
  final String id;
  final String utilisateurId;
  final String nom;
  final String? terme;
  final String? categorieId;
  final String? typeId;
  final double? prixMin;
  final double? prixMax;
  final double? surfaceMin;
  final double? surfaceMax;
  final int? nombreChambresMin;
  final int? nombreChambresMax;
  final String? villeId;
  final String? quartierId;
  final double? latitude;
  final double? longitude;
  final double? rayon;
  final List<String> equipements;
  final bool alerteActive;
  final String frequenceAlerte;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  RechercheEnregistree({
    required this.id,
    required this.utilisateurId,
    required this.nom,
    this.terme,
    this.categorieId,
    this.typeId,
    this.prixMin,
    this.prixMax,
    this.surfaceMin,
    this.surfaceMax,
    this.nombreChambresMin,
    this.nombreChambresMax,
    this.villeId,
    this.quartierId,
    this.latitude,
    this.longitude,
    this.rayon,
    this.equipements = const [],
    this.alerteActive = false,
    this.frequenceAlerte = 'immediat',
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  RechercheEnregistree copyWith({
    String? id,
    String? utilisateurId,
    String? nom,
    String? terme,
    String? categorieId,
    String? typeId,
    double? prixMin,
    double? prixMax,
    double? surfaceMin,
    double? surfaceMax,
    int? nombreChambresMin,
    int? nombreChambresMax,
    String? villeId,
    String? quartierId,
    double? latitude,
    double? longitude,
    double? rayon,
    List<String>? equipements,
    bool? alerteActive,
    String? frequenceAlerte,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return RechercheEnregistree(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      nom: nom ?? this.nom,
      terme: terme ?? this.terme,
      categorieId: categorieId ?? this.categorieId,
      typeId: typeId ?? this.typeId,
      prixMin: prixMin ?? this.prixMin,
      prixMax: prixMax ?? this.prixMax,
      surfaceMin: surfaceMin ?? this.surfaceMin,
      surfaceMax: surfaceMax ?? this.surfaceMax,
      nombreChambresMin: nombreChambresMin ?? this.nombreChambresMin,
      nombreChambresMax: nombreChambresMax ?? this.nombreChambresMax,
      villeId: villeId ?? this.villeId,
      quartierId: quartierId ?? this.quartierId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rayon: rayon ?? this.rayon,
      equipements: equipements ?? this.equipements,
      alerteActive: alerteActive ?? this.alerteActive,
      frequenceAlerte: frequenceAlerte ?? this.frequenceAlerte,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'nom': nom,
      'terme': terme,
      'categorie_id': categorieId,
      'type_id': typeId,
      'prix_min': prixMin,
      'prix_max': prixMax,
      'surface_min': surfaceMin,
      'surface_max': surfaceMax,
      'nombre_chambres_min': nombreChambresMin,
      'nombre_chambres_max': nombreChambresMax,
      'ville_id': villeId,
      'quartier_id': quartierId,
      'latitude': latitude,
      'longitude': longitude,
      'rayon': rayon,
      'equipements': equipements,
      'alerte_active': alerteActive,
      'frequence_alerte': frequenceAlerte,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory RechercheEnregistree.fromMap(Map<String, dynamic> map) {
    return RechercheEnregistree(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      nom: map['nom'] as String,
      terme: map['terme'] as String?,
      categorieId: map['categorie_id'] as String?,
      typeId: map['type_id'] as String?,
      prixMin: (map['prix_min'] as num?)?.toDouble(),
      prixMax: (map['prix_max'] as num?)?.toDouble(),
      surfaceMin: (map['surface_min'] as num?)?.toDouble(),
      surfaceMax: (map['surface_max'] as num?)?.toDouble(),
      nombreChambresMin: map['nombre_chambres_min'] as int?,
      nombreChambresMax: map['nombre_chambres_max'] as int?,
      villeId: map['ville_id'] as String?,
      quartierId: map['quartier_id'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      rayon: (map['rayon'] as num?)?.toDouble(),
      equipements: List<String>.from(map['equipements'] as List? ?? []),
      alerteActive: map['alerte_active'] as bool? ?? false,
      frequenceAlerte: map['frequence_alerte'] as String? ?? 'immediat',
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory RechercheEnregistree.fromJson(String source) =>
      RechercheEnregistree.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RechercheEnregistree && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
