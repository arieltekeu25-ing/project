// Modèle de ville
class Ville {
  final String id;
  final String nom;
  final String? code;
  final String? pays;
  final String? region;
  final String? province;
  final double? latitude;
  final double? longitude;
  final int population;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Ville({
    required this.id,
    required this.nom,
    this.code,
    this.pays,
    this.region,
    this.province,
    this.latitude,
    this.longitude,
    this.population = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Ville copyWith({
    String? id,
    String? nom,
    String? code,
    String? pays,
    String? region,
    String? province,
    double? latitude,
    double? longitude,
    int? population,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Ville(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      code: code ?? this.code,
      pays: pays ?? this.pays,
      region: region ?? this.region,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      population: population ?? this.population,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'pays': pays,
      'region': region,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'population': population,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Ville.fromMap(Map<String, dynamic> map) {
    return Ville(
      id: map['id'] as String,
      nom: map['nom'] as String,
      code: map['code'] as String?,
      pays: map['pays'] as String?,
      region: map['region'] as String?,
      province: map['province'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      population: map['population'] as int? ?? 0,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Ville.fromJson(String source) =>
      Ville.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ville && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
