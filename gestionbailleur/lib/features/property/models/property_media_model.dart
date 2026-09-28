/// Modèle de données pour un média de logement (image ou vidéo Cloudinary)
class PropertyMediaModel {
  final String id;
  final String? propertyId;
  final String cloudinaryPublicId;
  final String secureUrl;
  final String resourceType; // 'image' ou 'video'
  final String? format;
  final int? width;
  final int? height;
  final double? duration;
  final int? fileSize;
  final int order;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PropertyMediaModel({
    required this.id,
    this.propertyId,
    required this.cloudinaryPublicId,
    required this.secureUrl,
    required this.resourceType,
    this.format,
    this.width,
    this.height,
    this.duration,
    this.fileSize,
    required this.order,
    required this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  bool get isImage => resourceType == 'image';
  bool get isVideo => resourceType == 'video';

  factory PropertyMediaModel.fromJson(Map<String, dynamic> json) {
    return PropertyMediaModel(
      id: json['id']?.toString() ?? '',
      propertyId: json['property']?.toString(),
      cloudinaryPublicId: json['cloudinary_public_id']?.toString() ?? '',
      secureUrl: json['secure_url']?.toString() ?? '',
      resourceType: json['resource_type']?.toString() ?? 'image',
      format: json['format']?.toString(),
      width: json['width'] != null ? (json['width'] as num).toInt() : null,
      height: json['height'] != null ? (json['height'] as num).toInt() : null,
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
      fileSize: json['file_size'] != null ? (json['file_size'] as num).toInt() : null,
      order: json['order'] != null ? (json['order'] as num).toInt() : 0,
      isPrimary: json['is_primary'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property': propertyId,
      'cloudinary_public_id': cloudinaryPublicId,
      'secure_url': secureUrl,
      'resource_type': resourceType,
      'format': format,
      'width': width,
      'height': height,
      'duration': duration,
      'file_size': fileSize,
      'order': order,
      'is_primary': isPrimary,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PropertyMediaModel copyWith({
    String? id,
    String? propertyId,
    String? cloudinaryPublicId,
    String? secureUrl,
    String? resourceType,
    String? format,
    int? width,
    int? height,
    double? duration,
    int? fileSize,
    int? order,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyMediaModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      cloudinaryPublicId: cloudinaryPublicId ?? this.cloudinaryPublicId,
      secureUrl: secureUrl ?? this.secureUrl,
      resourceType: resourceType ?? this.resourceType,
      format: format ?? this.format,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      order: order ?? this.order,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
