// Modèle de photo de logement
class PhotoLogement {
  final String id;
  final String logementId;
  final String url;
  final String? miniatureUrl;
  final String? description;
  final int ordre;
  final bool estPrincipale;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  PhotoLogement({
    required this.id,
    required this.logementId,
    required this.url,
    this.miniatureUrl,
    this.description,
    this.ordre = 0,
    this.estPrincipale = false,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  PhotoLogement copyWith({
    String? id,
    String? logementId,
    String? url,
    String? miniatureUrl,
    String? description,
    int? ordre,
    bool? estPrincipale,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return PhotoLogement(
      id: id ?? this.id,
      logementId: logementId ?? this.logementId,
      url: url ?? this.url,
      miniatureUrl: miniatureUrl ?? this.miniatureUrl,
      description: description ?? this.description,
      ordre: ordre ?? this.ordre,
      estPrincipale: estPrincipale ?? this.estPrincipale,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logement_id': logementId,
      'url': url,
      'miniature_url': miniatureUrl,
      'description': description,
      'ordre': ordre,
      'est_principale': estPrincipale,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory PhotoLogement.fromMap(Map<String, dynamic> map) {
    return PhotoLogement(
      id: map['id'] as String,
      logementId: map['logement_id'] as String,
      url: map['url'] as String,
      miniatureUrl: map['miniature_url'] as String?,
      description: map['description'] as String?,
      ordre: map['ordre'] as int? ?? 0,
      estPrincipale: map['est_principale'] as bool? ?? false,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory PhotoLogement.fromJson(String source) =>
      PhotoLogement.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoLogement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
