/// Mode de recherche préparé pour l'évolution IA
enum SearchMode {
  manual,
  advanced,
  ai,
}

/// Modèle représentant les critères de recherche réels et filtres
class SearchFilterModel {
  final String? query;
  final String? city;
  final String? district;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final double? minSurface;
  final double? maxSurface;
  final int? bedrooms;
  final int? rooms;
  final bool? furnished;
  final double? userLatitude;
  final double? userLongitude;
  final double? radiusKm;
  final String ordering;
  final SearchMode mode;

  const SearchFilterModel({
    this.query,
    this.city,
    this.district,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minSurface,
    this.maxSurface,
    this.bedrooms,
    this.rooms,
    this.furnished,
    this.userLatitude,
    this.userLongitude,
    this.radiusKm = 50.0,
    this.ordering = '-created_at',
    this.mode = SearchMode.manual,
  });

  bool get hasActiveFilters {
    return (query != null && query!.trim().isNotEmpty) ||
        (city != null && city!.isNotEmpty) ||
        (district != null && district!.isNotEmpty) ||
        (propertyType != null && propertyType!.isNotEmpty) ||
        minPrice != null ||
        maxPrice != null ||
        minSurface != null ||
        maxSurface != null ||
        bedrooms != null ||
        rooms != null ||
        furnished == true ||
        (userLatitude != null && userLongitude != null);
  }

  int get activeFiltersCount {
    int count = 0;
    if (query != null && query!.trim().isNotEmpty) count++;
    if (city != null && city!.isNotEmpty) count++;
    if (district != null && district!.isNotEmpty) count++;
    if (propertyType != null && propertyType!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minSurface != null || maxSurface != null) count++;
    if (bedrooms != null) count++;
    if (rooms != null) count++;
    if (furnished == true) count++;
    if (userLatitude != null && userLongitude != null) count++;
    return count;
  }

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (query != null && query!.trim().isNotEmpty) {
      params['q'] = query!.trim();
    }
    if (city != null && city!.isNotEmpty) {
      params['city'] = city!;
    }
    if (district != null && district!.isNotEmpty) {
      params['district'] = district!;
    }
    if (propertyType != null && propertyType!.isNotEmpty) {
      params['property_type'] = propertyType!;
    }
    if (minPrice != null && minPrice! > 0) {
      params['min_price'] = minPrice!.toStringAsFixed(0);
    }
    if (maxPrice != null && maxPrice! > 0) {
      params['max_price'] = maxPrice!.toStringAsFixed(0);
    }
    if (minSurface != null && minSurface! > 0) {
      params['min_surface'] = minSurface!.toStringAsFixed(0);
    }
    if (maxSurface != null && maxSurface! > 0) {
      params['max_surface'] = maxSurface!.toStringAsFixed(0);
    }
    if (bedrooms != null && bedrooms! > 0) {
      params['bedrooms'] = bedrooms.toString();
    }
    if (rooms != null && rooms! > 0) {
      params['rooms'] = rooms.toString();
    }
    if (furnished == true) {
      params['furnished'] = 'true';
    }
    if (userLatitude != null && userLongitude != null) {
      params['latitude'] = userLatitude.toString();
      params['longitude'] = userLongitude.toString();
      if (radiusKm != null) {
        params['radius_km'] = radiusKm!.toStringAsFixed(1);
      }
    }
    if (ordering.isNotEmpty) {
      params['ordering'] = ordering;
    }

    return params;
  }

  SearchFilterModel copyWith({
    String? query,
    String? city,
    String? district,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    double? minSurface,
    double? maxSurface,
    int? bedrooms,
    int? rooms,
    bool? furnished,
    double? userLatitude,
    double? userLongitude,
    double? radiusKm,
    String? ordering,
    SearchMode? mode,
    bool clearQuery = false,
    bool clearCity = false,
    bool clearDistrict = false,
    bool clearPropertyType = false,
    bool clearPrice = false,
    bool clearSurface = false,
    bool clearBedrooms = false,
    bool clearLocation = false,
  }) {
    return SearchFilterModel(
      query: clearQuery ? null : (query ?? this.query),
      city: clearCity ? null : (city ?? this.city),
      district: clearDistrict ? null : (district ?? this.district),
      propertyType: clearPropertyType ? null : (propertyType ?? this.propertyType),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      minSurface: clearSurface ? null : (minSurface ?? this.minSurface),
      maxSurface: clearSurface ? null : (maxSurface ?? this.maxSurface),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      rooms: rooms ?? this.rooms,
      furnished: furnished ?? this.furnished,
      userLatitude: clearLocation ? null : (userLatitude ?? this.userLatitude),
      userLongitude: clearLocation ? null : (userLongitude ?? this.userLongitude),
      radiusKm: radiusKm ?? this.radiusKm,
      ordering: ordering ?? this.ordering,
      mode: mode ?? this.mode,
    );
  }
}
