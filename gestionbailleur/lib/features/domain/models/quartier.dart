// Modèle de quartier
class Quartier {
  final String id;
  final String nom;
  final String villeId;
  final String? code;
  final String? description;
  final double? latitude;
  final double? longitude;
  final int population;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Quartier({
    required this.id,
    required this.nom,
    required this.villeId,
    this.code,
    this.description,
    this.latitude,
    this.longitude,
    this.population = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Quartier copyWith({
    String? id,
    String? nom,
    String? villeId,
    String? code,
    String? description,
    double? latitude,
    double? longitude,
    int? population,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Quartier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      villeId: villeId ?? this.villeId,
      code: code ?? this.code,
      description: description ?? this.description,
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
      'ville_id': villeId,
      'code': code,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'population': population,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Quartier.fromMap(Map<String, dynamic> map) {
    return Quartier(
      id: map['id'] as String,
      nom: map['nom'] as String,
      villeId: map['ville_id'] as String,
      code: map['code'] as String?,
      description: map['description'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      population: map['population'] as int? ?? 0,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Quartier.fromJson(String source) =>
      Quartier.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quartier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
