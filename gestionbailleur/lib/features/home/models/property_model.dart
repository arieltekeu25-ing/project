import 'package:gestionbailleur/features/property/models/property_media_model.dart';

/// Modèle de données pour un logement
class PropertyModel {
  final String id;
  final String title;
  final String description;
  final String propertyType;
  final String status;
  final double rentPrice;
  final double? charges;
  final double? deposit;
  final double surface;
  final int rooms;
  final int bedrooms;
  final int bathrooms;
  final int? floor;
  final bool furnished;
  final bool parking;
  final bool balcony;
  final bool terrace;
  final bool elevator;
  final bool garden;
  final bool pool;
  final bool airConditioning;
  final String heating;
  final String? mainPhoto;
  final List<String> images;
  final List<PropertyMediaModel> mediaList;
  final String? videoUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final int viewsCount;
  final int inquiriesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? landlordId;
  final String landlordName;
  final String landlordEmail;
  final String? landlordPhoto;
  final String landlordStatus;
  final bool landlordIsVerified;
  final AddressDetails? addressDetails;
  final DateTime? availableFrom;
  final String? minimumRentDuration;
  final bool isFavorite;
  final bool isVisible;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.status,
    required this.rentPrice,
    this.charges,
    this.deposit,
    required this.surface,
    required this.rooms,
    required this.bedrooms,
    required this.bathrooms,
    this.floor,
    required this.furnished,
    required this.parking,
    required this.balcony,
    required this.terrace,
    required this.elevator,
    required this.garden,
    required this.pool,
    required this.airConditioning,
    required this.heating,
    this.mainPhoto,
    this.images = const [],
    this.mediaList = const [],
    this.videoUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
    required this.viewsCount,
    required this.inquiriesCount,
    required this.createdAt,
    required this.updatedAt,
    this.landlordId,
    required this.landlordName,
    required this.landlordEmail,
    this.landlordPhoto,
    this.landlordStatus = 'EN_ATTENTE',
    this.landlordIsVerified = false,
    this.addressDetails,
    this.availableFrom,
    this.minimumRentDuration,
    this.isFavorite = false,
    this.isVisible = true,
  });

  static double _toDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static double? _toNullableDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  static int _toInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
    return defaultVal;
  }

  static int? _toNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? double.tryParse(val)?.toInt();
    return null;
  }

  static bool _toBool(dynamic val, [bool defaultVal = false]) {
    if (val == null) return defaultVal;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'oui';
    }
    return defaultVal;
  }

  static String _formatHeatingLabel(dynamic val) {
    if (val == null) return '';
    if (val is bool) return val ? 'Oui' : 'Non';
    final s = val.toString().toLowerCase();
    if (s == 'true' || s == '1' || s == 'oui' || s == 'yes') return 'Oui';
    if (s == 'false' || s == '0' || s == 'non' || s == 'no') return 'Non';
    return val.toString();
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('property') && json['property'] is Map<String, dynamic>) {
      data = json['property'] as Map<String, dynamic>;
    } else if (json.containsKey('property_details') && json['property_details'] is Map<String, dynamic>) {
      data = json['property_details'] as Map<String, dynamic>;
    }

    List<PropertyMediaModel> parsedMediaList = [];
    if (data['media'] is List) {
      parsedMediaList = (data['media'] as List)
          .map((e) => PropertyMediaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String> parsedImages = [];
    if (data['images'] is List) {
      parsedImages = (data['images'] as List).map((e) => e.toString()).toList();
    } else if (parsedMediaList.isNotEmpty) {
      parsedImages = parsedMediaList.where((m) => m.isImage).map((m) => m.secureUrl).toList();
    } else if (data['main_photo'] != null && data['main_photo'].toString().isNotEmpty) {
      parsedImages.add(data['main_photo'].toString());
    }

    AddressDetails? addr;
    if (data['address_details'] != null && data['address_details'] is Map<String, dynamic>) {
      addr = AddressDetails.fromJson(data['address_details']);
    }

    double? lat = data['latitude'] != null ? _toNullableDouble(data['latitude']) : addr?.latitude;
    double? lng = data['longitude'] != null ? _toNullableDouble(data['longitude']) : addr?.longitude;
    double? dist = _toNullableDouble(data['distance_km']);

    return PropertyModel(
      id: data['id']?.toString() ?? json['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      propertyType: data['property_type']?.toString() ?? 'APARTMENT',
      status: data['status']?.toString() ?? 'DRAFT',
      rentPrice: _toDouble(data['rent_price']),
      charges: _toNullableDouble(data['charges']),
      deposit: _toNullableDouble(data['deposit']),
      surface: _toDouble(data['surface']),
      rooms: _toInt(data['rooms']),
      bedrooms: _toInt(data['bedrooms']),
      bathrooms: _toInt(data['bathrooms']),
      floor: _toNullableInt(data['floor']),
      furnished: _toBool(data['furnished']),
      parking: _toBool(data['parking']),
      balcony: _toBool(data['balcony']),
      terrace: _toBool(data['terrace']),
      elevator: _toBool(data['elevator']),
      garden: _toBool(data['garden']),
      pool: _toBool(data['pool']),
      airConditioning: _toBool(data['air_conditioning']),
      heating: _formatHeatingLabel(data['heating']),
      mainPhoto: data['main_photo']?.toString(),
      images: parsedImages,
      mediaList: parsedMediaList,
      videoUrl: data['video_url']?.toString() ?? data['video']?.toString(),
      latitude: lat,
      longitude: lng,
      distanceKm: dist,
      viewsCount: _toInt(data['views_count']),
      inquiriesCount: _toInt(data['inquiries_count']),
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.tryParse(data['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      landlordId: data['landlord']?.toString() ?? data['landlord_id']?.toString(),
      landlordName: data['landlord_name']?.toString() ?? '',
      landlordEmail: data['landlord_email']?.toString() ?? '',
      landlordPhoto: data['landlord_photo']?.toString(),
      landlordStatus: data['landlord_status']?.toString() ?? 'ACTIF',
      landlordIsVerified: _toBool(data['landlord_is_verified'], data['landlord_status'] == 'ACTIF'),
      addressDetails: addr,
      availableFrom: data['available_from'] != null 
          ? DateTime.tryParse(data['available_from'].toString()) 
          : null,
      minimumRentDuration: data['minimum_rent_duration']?.toString(),
      isFavorite: _toBool(data['is_favorite']),
      isVisible: _toBool(data['is_visible'], true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'property_type': propertyType,
      'status': status,
      'rent_price': rentPrice,
      'charges': charges,
      'deposit': deposit,
      'surface': surface,
      'rooms': rooms,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floor': floor,
      'furnished': furnished,
      'parking': parking,
      'balcony': balcony,
      'terrace': terrace,
      'elevator': elevator,
      'garden': garden,
      'pool': pool,
      'air_conditioning': airConditioning,
      'heating': heating,
      'main_photo': mainPhoto,
      'images': images,
      'video_url': videoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'views_count': viewsCount,
      'inquiries_count': inquiriesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'landlord_name': landlordName,
      'landlord_email': landlordEmail,
      'landlord_photo': landlordPhoto,
      'landlord_status': landlordStatus,
      'landlord_is_verified': landlordIsVerified,
      'address_details': addressDetails?.toJson(),
      'available_from': availableFrom?.toIso8601String(),
      'minimum_rent_duration': minimumRentDuration,
      'is_favorite': isFavorite,
      'is_visible': isVisible,
    };
  }

  String get city => addressDetails?.city ?? '';
  String get district => addressDetails?.district ?? '';
  String get country => addressDetails?.country ?? '';
  String get postalCode => addressDetails?.postalCode ?? '';
  String get street => addressDetails?.street ?? '';

  String get formattedPrice => '${rentPrice.toStringAsFixed(0)} FCFA';
  String get formattedSurface => '${surface.toStringAsFixed(0)} m²';

  double? get effectiveLatitude => latitude ?? addressDetails?.latitude;
  double? get effectiveLongitude => longitude ?? addressDetails?.longitude;

  String get formattedDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1.0) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    String? propertyType,
    String? status,
    double? rentPrice,
    double? charges,
    double? deposit,
    double? surface,
    int? rooms,
    int? bedrooms,
    int? bathrooms,
    int? floor,
    bool? furnished,
    bool? parking,
    bool? balcony,
    bool? terrace,
    bool? elevator,
    bool? garden,
    bool? pool,
    bool? airConditioning,
    String? heating,
    String? mainPhoto,
    List<String>? images,
    String? videoUrl,
    double? latitude,
    double? longitude,
    double? distanceKm,
    int? viewsCount,
    int? inquiriesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? landlordId,
    String? landlordName,
    String? landlordEmail,
    String? landlordPhoto,
    String? landlordStatus,
    bool? landlordIsVerified,
    AddressDetails? addressDetails,
    DateTime? availableFrom,
    String? minimumRentDuration,
    bool? isFavorite,
    bool? isVisible,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      status: status ?? this.status,
      rentPrice: rentPrice ?? this.rentPrice,
      charges: charges ?? this.charges,
      deposit: deposit ?? this.deposit,
      surface: surface ?? this.surface,
      rooms: rooms ?? this.rooms,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      floor: floor ?? this.floor,
      furnished: furnished ?? this.furnished,
      parking: parking ?? this.parking,
      balcony: balcony ?? this.balcony,
      terrace: terrace ?? this.terrace,
      elevator: elevator ?? this.elevator,
      garden: garden ?? this.garden,
      pool: pool ?? this.pool,
      airConditioning: airConditioning ?? this.airConditioning,
      heating: heating ?? this.heating,
      mainPhoto: mainPhoto ?? this.mainPhoto,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      viewsCount: viewsCount ?? this.viewsCount,
      inquiriesCount: inquiriesCount ?? this.inquiriesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      landlordId: landlordId ?? this.landlordId,
      landlordName: landlordName ?? this.landlordName,
      landlordEmail: landlordEmail ?? this.landlordEmail,
      landlordPhoto: landlordPhoto ?? this.landlordPhoto,
      landlordStatus: landlordStatus ?? this.landlordStatus,
      landlordIsVerified: landlordIsVerified ?? this.landlordIsVerified,
      addressDetails: addressDetails ?? this.addressDetails,
      availableFrom: availableFrom ?? this.availableFrom,
      minimumRentDuration: minimumRentDuration ?? this.minimumRentDuration,
      isFavorite: isFavorite ?? this.isFavorite,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class AddressDetails {
  final String? street;
  final String? city;
  final String? district;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  AddressDetails({
    this.street,
    this.city,
    this.district,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      street: json['street'],
      city: json['city'],
      district: json['district'],
      country: json['country'],
      postalCode: json['postal_code'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'district': district,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
