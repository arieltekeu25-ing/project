import '../../home/models/property_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/network/network_exceptions.dart';

/// Repository pour la gestion des favoris de l'utilisateur
class FavoritesRepository {
  final ApiService _apiService;

  FavoritesRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Récupérer la liste réelle des favoris de l'utilisateur connecté
  Future<List<PropertyModel>> getFavorites() async {
    try {
      final response = await _apiService.get(
        '/api/v1/favorites/',
        requireAuth: true,
      );

      List<PropertyModel> properties = [];
      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response.containsKey('results')) {
        rawList = response['results'] as List<dynamic>;
      }

      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            properties.add(PropertyModel.fromJson(item).copyWith(isFavorite: true));
          } catch (_) {
            // Passer sur les items mal formés
          }
        }
      }
      return properties;
    } catch (e) {
      throw _handleError(e);
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
      throw _handleError(e);
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
      throw _handleError(e);
    }
  }

  /// Gestion unifiée des erreurs HTTP/Réseau
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
