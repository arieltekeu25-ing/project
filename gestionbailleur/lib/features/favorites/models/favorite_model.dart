import '../../home/models/property_model.dart';

/// Modèle pour un favori utilisateur
class FavoriteModel {
  final String id;
  final String propertyId;
  final PropertyModel property;
  final DateTime? createdAt;

  FavoriteModel({
    required this.id,
    required this.propertyId,
    required this.property,
    this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    PropertyModel prop;
    if (json.containsKey('property') && json['property'] is Map<String, dynamic>) {
      prop = PropertyModel.fromJson(json['property'] as Map<String, dynamic>);
    } else {
      prop = PropertyModel.fromJson(json);
    }

    return FavoriteModel(
      id: json['id']?.toString() ?? prop.id,
      propertyId: json['property_id']?.toString() ?? prop.id,
      property: prop.copyWith(isFavorite: true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property': property.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  FavoriteModel copyWith({
    String? id,
    String? propertyId,
    PropertyModel? property,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      property: property ?? this.property,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
