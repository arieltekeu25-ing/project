// Modèle de planning de visite
class PlanningVisite {
  final String id;
  final String bailleurId;
  final String logementId;
  final List<String> creneaux;
  final String? instructions;
  final int dureeVisite;
  final int delaiReservation;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  PlanningVisite({
    required this.id,
    required this.bailleurId,
    required this.logementId,
    this.creneaux = const [],
    this.instructions,
    this.dureeVisite = 30,
    this.delaiReservation = 24,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  PlanningVisite copyWith({
    String? id,
    String? bailleurId,
    String? logementId,
    List<String>? creneaux,
    String? instructions,
    int? dureeVisite,
    int? delaiReservation,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return PlanningVisite(
      id: id ?? this.id,
      bailleurId: bailleurId ?? this.bailleurId,
      logementId: logementId ?? this.logementId,
      creneaux: creneaux ?? this.creneaux,
      instructions: instructions ?? this.instructions,
      dureeVisite: dureeVisite ?? this.dureeVisite,
      delaiReservation: delaiReservation ?? this.delaiReservation,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bailleur_id': bailleurId,
      'logement_id': logementId,
      'creneaux': creneaux,
      'instructions': instructions,
      'duree_visite': dureeVisite,
      'delai_reservation': delaiReservation,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory PlanningVisite.fromMap(Map<String, dynamic> map) {
    return PlanningVisite(
      id: map['id'] as String,
      bailleurId: map['bailleur_id'] as String,
      logementId: map['logement_id'] as String,
      creneaux: List<String>.from(map['creneaux'] as List? ?? []),
      instructions: map['instructions'] as String?,
      dureeVisite: map['duree_visite'] as int? ?? 30,
      delaiReservation: map['delai_reservation'] as int? ?? 24,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory PlanningVisite.fromJson(String source) =>
      PlanningVisite.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanningVisite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
