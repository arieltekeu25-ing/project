// Modèle de vidéo de logement
class VideoLogement {
  final String id;
  final String logementId;
  final String url;
  final String? miniatureUrl;
  final String? description;
  final int duree;
  final int ordre;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  VideoLogement({
    required this.id,
    required this.logementId,
    required this.url,
    this.miniatureUrl,
    this.description,
    this.duree = 0,
    this.ordre = 0,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
  });

  VideoLogement copyWith({
    String? id,
    String? logementId,
    String? url,
    String? miniatureUrl,
    String? description,
    int? duree,
    int? ordre,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return VideoLogement(
      id: id ?? this.id,
      logementId: logementId ?? this.logementId,
      url: url ?? this.url,
      miniatureUrl: miniatureUrl ?? this.miniatureUrl,
      description: description ?? this.description,
      duree: duree ?? this.duree,
      ordre: ordre ?? this.ordre,
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
      'duree': duree,
      'ordre': ordre,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory VideoLogement.fromMap(Map<String, dynamic> map) {
    return VideoLogement(
      id: map['id'] as String,
      logementId: map['logement_id'] as String,
      url: map['url'] as String,
      miniatureUrl: map['miniature_url'] as String?,
      description: map['description'] as String?,
      duree: map['duree'] as int? ?? 0,
      ordre: map['ordre'] as int? ?? 0,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: DateTime.parse(map['date_modification'] as String),
    );
  }

  String toJson() => toMap().toString();

  factory VideoLogement.fromJson(String source) =>
      VideoLogement.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoLogement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
