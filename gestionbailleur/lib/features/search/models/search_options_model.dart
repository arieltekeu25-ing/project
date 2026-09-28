/// Modèle contenant les options dynamiques de filtres réellement renvoyées par la base PostgreSQL
class SearchOptionsModel {
  final List<String> cities;
  final List<String> districts;
  final List<String> propertyTypes;
  final double minPrice;
  final double maxPrice;

  const SearchOptionsModel({
    this.cities = const [],
    this.districts = const [],
    this.propertyTypes = const [],
    this.minPrice = 0.0,
    this.maxPrice = 0.0,
  });

  factory SearchOptionsModel.fromJson(Map<String, dynamic> json) {
    return SearchOptionsModel(
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      districts: (json['districts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      propertyTypes: (json['property_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SearchOptionsModel copyWith({
    List<String>? cities,
    List<String>? districts,
    List<String>? propertyTypes,
    double? minPrice,
    double? maxPrice,
  }) {
    return SearchOptionsModel(
      cities: cities ?? this.cities,
      districts: districts ?? this.districts,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}
