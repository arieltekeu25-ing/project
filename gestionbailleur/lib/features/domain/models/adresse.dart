// Modèle d'adresse
class Adresse {
  final String id;
  final String rue;
  final String? numero;
  final String? complement;
  final String codePostal;
  final String villeId;
  final String? quartierId;
  final double? latitude;
  final double? longitude;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Adresse({
    required this.id,
    required this.rue,
    this.numero,
    this.complement,
    required this.codePostal,
    required this.villeId,
    this.quartierId,
    this.latitude,
    this.longitude,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  Adresse copyWith({
    String? id,
    String? rue,
    String? numero,
    String? complement,
    String? codePostal,
    String? villeId,
    String? quartierId,
    double? latitude,
    double? longitude,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Adresse(
      id: id ?? this.id,
      rue: rue ?? this.rue,
      numero: numero ?? this.numero,
      complement: complement ?? this.complement,
      codePostal: codePostal ?? this.codePostal,
      villeId: villeId ?? this.villeId,
      quartierId: quartierId ?? this.quartierId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rue': rue,
      'numero': numero,
      'complement': complement,
      'code_postal': codePostal,
      'ville_id': villeId,
      'quartier_id': quartierId,
      'latitude': latitude,
      'longitude': longitude,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Adresse.fromMap(Map<String, dynamic> map) {
    return Adresse(
      id: map['id'] as String,
      rue: map['rue'] as String,
      numero: map['numero'] as String?,
      complement: map['complement'] as String?,
      codePostal: map['code_postal'] as String,
      villeId: map['ville_id'] as String,
      quartierId: map['quartier_id'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory Adresse.fromJson(String source) =>
      Adresse.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Adresse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
