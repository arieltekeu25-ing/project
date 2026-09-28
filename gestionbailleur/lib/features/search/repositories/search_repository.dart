import '../../../core/services/api_service.dart';
import '../../../core/network/network_exceptions.dart';
import '../../home/models/property_model.dart';
import '../models/search_filter_model.dart';
import '../models/search_options_model.dart';

/// Repository chargé de la communication HTTP avec l'API REST de recherche et filtres
class SearchRepository {
  final ApiService _apiService;

  SearchRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Exécuter la recherche de logements avec filtres et coordonnées GPS réelles
  Future<List<PropertyModel>> searchProperties(SearchFilterModel filters) async {
    try {
      final queryParams = filters.toQueryParams();
      
      // Amélioration: si query est vide mais city/district sont présents, 
      // utiliser la recherche générique qui recherche dans tous les champs
      if ((filters.query == null || filters.query!.trim().isEmpty) && 
          (filters.city != null || filters.district != null)) {
        // Ajouter la ville/quartier comme query pour une recherche plus large
        if (filters.city != null && filters.city!.isNotEmpty) {
          queryParams['q'] = filters.city!;
          if (filters.district != null && filters.district!.isNotEmpty) {
            queryParams['q'] = '$filters.city $filters.district';
          }
        }
      }
      
      final response = await _apiService.get(
        '/api/v1/properties/search/',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      List<PropertyModel> properties = [];
      if (response is List) {
        properties = response.map((json) => PropertyModel.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('results')) {
        final results = response['results'] as List;
        properties = results.map((json) => PropertyModel.fromJson(json)).toList();
      }
      return properties;
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt que de lancer une exception
      // Cela permet à l'UI de continuer à fonctionner même si la recherche échoue
      return [];
    }
  }

  /// Récupérer les options réelles de filtrage depuis PostgreSQL (villes, quartiers, types, loyers)
  Future<SearchOptionsModel> getFilterOptions() async {
    try {
      final response = await _apiService.get('/api/v1/properties/options/');
      if (response is Map<String, dynamic>) {
        return SearchOptionsModel.fromJson(response);
      }
      return const SearchOptionsModel();
    } catch (e) {
      // Ne pas injecter de listes fictives : laisser l'UI afficher l'état vide/erreur
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
