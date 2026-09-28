import 'package:flutter/foundation.dart';
import 'package:gestionbailleur/core/network/api_endpoints.dart';
import 'package:gestionbailleur/core/network/network_exceptions.dart';
import 'package:gestionbailleur/core/services/api_service.dart';
import 'package:gestionbailleur/core/services/cache_service.dart';
import '../models/property_model.dart';

/// Repository pour la gestion des logements
class PropertyRepository {
  final ApiService _apiService = ApiService.instance;
  final CacheService _cacheService = CacheService.instance;

  /// Récupérer tous les logements disponibles
  Future<List<PropertyModel>> getAllProperties({bool useCache = true, int page = 1, int limit = 20}) async {
    final cacheKey = 'all_properties_page_${page}_limit_$limit';
    
    // Essayer de récupérer du cache
    if (useCache) {
      final cachedData = _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => PropertyModel.fromJson(json)).toList();
      }
    }
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': limit.toString(),
      };
      
      final response = await _apiService.get(
        '/api/v1/properties/',
        queryParams: queryParams,
        requireAuth: false,
      );
      
      List<PropertyModel> properties;
      if (response is List) {
        properties = response.map((json) => PropertyModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        properties = results.map((json) => PropertyModel.fromJson(json)).toList();
      } else {
        properties = [];
      }
      
      // Mettre en cache (30 minutes)
      if (properties.isNotEmpty) {
        await _cacheService.set(
          cacheKey,
          properties.map((p) => p.toJson()).toList(),
          durationMinutes: 30,
        );
      }
      
      return properties;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les logements d'un bailleur spécifique
  Future<List<PropertyModel>> getLandlordProperties(String landlordId, {bool useCache = true}) async {
    final cacheKey = 'landlord_properties_$landlordId';
    
    // Essayer de récupérer du cache
    if (useCache) {
      final cachedData = _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedData != null) {
        return cachedData.map((json) => PropertyModel.fromJson(json)).toList();
      }
    }
    
    try {
      final response = await _apiService.get(
        '/api/v1/properties/?landlord=$landlordId',
        requireAuth: true,
      );
      
      List<PropertyModel> properties;
      if (response is List) {
        properties = response.map((json) => PropertyModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        properties = results.map((json) => PropertyModel.fromJson(json)).toList();
      } else {
        properties = [];
      }
      
      // Mettre en cache (15 minutes)
      if (properties.isNotEmpty) {
        await _cacheService.set(
          cacheKey,
          properties.map((p) => p.toJson()).toList(),
          durationMinutes: 15,
        );
      }
      
      return properties;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un logement par son ID
  Future<PropertyModel> getPropertyById(String id) async {
    try {
      if (kDebugMode) {
        print('Fetching property with ID: $id');
      }
      final response = await _apiService.get(
        '/api/v1/properties/$id/',
        requireAuth: false,
      );
      
      if (kDebugMode) {
        print('Property response: $response');
      }
      return PropertyModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching property: $e');
      }
      throw _handleError(e);
    }
  }

  /// Rechercher des logements
  Future<List<PropertyModel>> searchProperties({
    String? city,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    bool? furnished,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (city != null) queryParams['city'] = city;
      if (propertyType != null) queryParams['property_type'] = propertyType;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minBedrooms != null) queryParams['min_bedrooms'] = minBedrooms.toString();
      if (maxBedrooms != null) queryParams['max_bedrooms'] = maxBedrooms.toString();
      if (furnished != null) queryParams['furnished'] = furnished.toString();

      final response = await _apiService.get(
        '/api/v1/properties/search/',
        requireAuth: false,
        queryParams: queryParams,
      );
      
      if (response is List) {
        return response.map((json) => PropertyModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        return results.map((json) => PropertyModel.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Créer un nouveau logement
  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.propertyCreate,
        body: data,
        requireAuth: true,
      );
      
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour un logement
  Future<PropertyModel> updateProperty(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/api/v1/properties/$id/update/',
        body: data,
        requireAuth: true,
      );
      
      // Invalider le cache pour forcer le rechargement
      await _cacheService.remove('all_properties_page_1_limit_20');
      await _cacheService.remove('landlord_properties_$id');
      
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour partiellement un logement (PATCH)
  Future<PropertyModel> patchProperty(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/api/v1/properties/$id/update/',
        body: data,
        requireAuth: true,
      );
      
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Publier un logement (statut -> PUBLISHED)
  Future<PropertyModel> publishProperty(String id) async {
    try {
      final response = await _apiService.post(
        '/api/v1/properties/$id/publish/',
        requireAuth: true,
      );
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Masquer un logement (statut -> HIDDEN)
  Future<PropertyModel> hideProperty(String id) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.propertyHide(id),
        requireAuth: true,
      );
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Afficher un logement (statut -> PUBLISHED)
  Future<PropertyModel> unhideProperty(String id) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.propertyUnhide(id),
        requireAuth: true,
      );
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer un logement
  Future<void> deleteProperty(String id) async {
    try {
      await _apiService.delete(
        ApiEndpoints.propertyDelete(id),
        requireAuth: true,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer la liste des favoris
  Future<List<PropertyModel>> getFavorites() async {
    try {
      final response = await _apiService.get(
        '/api/v1/favorites/',
        requireAuth: true,
      );
      
      if (response is List) {
        return response.map((json) => PropertyModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        return results.map((json) => PropertyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Si l'endpoint n'est pas encore actif, renvoyer liste vide propre
      return [];
    }
  }

  /// Ajouter un logement aux favoris
  Future<bool> addFavorite(String propertyId) async {
    try {
      await _apiService.post(
        '/api/v1/favorites/',
        body: {'property_id': propertyId},
        requireAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retirer un logement des favoris
  Future<bool> removeFavorite(String propertyId) async {
    try {
      await _apiService.delete(
        '/api/v1/favorites/$propertyId/',
        requireAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gérer les erreurs
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
