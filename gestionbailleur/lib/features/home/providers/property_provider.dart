import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';

/// État du provider de propriétés
class PropertyState {
  final List<PropertyModel> properties;
  final List<PropertyModel> landlordProperties;
  final List<PropertyModel> favoriteProperties;
  final PropertyModel? selectedProperty;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasAttemptedFetch;
  final bool hasAttemptedLandlordFetch;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const PropertyState({
    this.properties = const [],
    this.landlordProperties = const [],
    this.favoriteProperties = const [],
    this.selectedProperty,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasAttemptedFetch = false,
    this.hasAttemptedLandlordFetch = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  PropertyState copyWith({
    List<PropertyModel>? properties,
    List<PropertyModel>? landlordProperties,
    List<PropertyModel>? favoriteProperties,
    PropertyModel? selectedProperty,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasAttemptedFetch,
    bool? hasAttemptedLandlordFetch,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return PropertyState(
      properties: properties ?? this.properties,
      landlordProperties: landlordProperties ?? this.landlordProperties,
      favoriteProperties: favoriteProperties ?? this.favoriteProperties,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
      hasAttemptedLandlordFetch: hasAttemptedLandlordFetch ?? this.hasAttemptedLandlordFetch,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider du repository de propriétés
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository();
});

/// Provider pour l'état des propriétés
final propertyProvider = StateNotifierProvider<PropertyNotifier, PropertyState>(
  (ref) => PropertyNotifier(ref.read(propertyRepositoryProvider)),
);

/// Notifier pour la gestion des propriétés
class PropertyNotifier extends StateNotifier<PropertyState> {
  final PropertyRepository _repository;

  PropertyNotifier(this._repository) : super(const PropertyState());

  /// Charger tous les logements
  Future<void> loadAllProperties({bool refresh = false}) async {
    // Note: Les bailleurs non validés peuvent voir les logements disponibles
    // La restriction s'applique uniquement à leurs propres actions de publication
    
    if (!refresh && state.hasAttemptedFetch && state.errorMessage != null) {
      return;
    }
    
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 1,
        properties: [],
        hasAttemptedFetch: false,
      );
    } else if (state.properties.isNotEmpty) {
      try {
        final cachedProperties = await _repository.getAllProperties(useCache: true);
        if (cachedProperties.isNotEmpty) {
          state = state.copyWith(properties: cachedProperties, hasAttemptedFetch: true);
          return;
        }
      } catch (e) {
        // Fallthrough
      }
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    
    try {
      final properties = await _repository.getAllProperties(
        useCache: !refresh,
        page: 1,
        limit: 20,
      );
      state = state.copyWith(
        properties: properties,
        isLoading: false,
        hasAttemptedFetch: true,
        currentPage: 1,
        hasMore: properties.length >= 20,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger les favoris
  Future<void> loadFavorites() async {
    try {
      final favs = await _repository.getFavorites();
      state = state.copyWith(favoriteProperties: favs);
    } catch (e) {
      // Ignore
    }
  }

  /// Publier un logement
  Future<void> publishProperty(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final published = await _repository.publishProperty(id);
      final updatedLandlordProps = state.landlordProperties.map((p) {
        return p.id == id ? published : p;
      }).toList();
      final updatedProps = state.properties.map((p) {
        return p.id == id ? published : p;
      }).toList();

      state = state.copyWith(
        properties: updatedProps,
        landlordProperties: updatedLandlordProps,
        selectedProperty: state.selectedProperty?.id == id ? published : state.selectedProperty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Masquer un logement
  Future<void> hideProperty(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final hidden = await _repository.hideProperty(id);
      final updatedLandlordProps = state.landlordProperties.map((p) {
        return p.id == id ? hidden : p;
      }).toList();
      final updatedProps = state.properties.map((p) {
        return p.id == id ? hidden : p;
      }).toList();

      state = state.copyWith(
        properties: updatedProps,
        landlordProperties: updatedLandlordProps,
        selectedProperty: state.selectedProperty?.id == id ? hidden : state.selectedProperty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Afficher un logement masqué
  Future<void> unhideProperty(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final unhidden = await _repository.unhideProperty(id);
      final updatedLandlordProps = state.landlordProperties.map((p) {
        return p.id == id ? unhidden : p;
      }).toList();
      final updatedProps = state.properties.map((p) {
        return p.id == id ? unhidden : p;
      }).toList();

      state = state.copyWith(
        properties: updatedProps,
        landlordProperties: updatedLandlordProps,
        selectedProperty: state.selectedProperty?.id == id ? unhidden : state.selectedProperty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Charger plus de propriétés (pagination)
  Future<void> loadMoreProperties() async {
    if (state.isLoadingMore || !state.hasMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final newProperties = await _repository.getAllProperties(
        useCache: false,
        page: nextPage,
        limit: 20,
      );
      
      state = state.copyWith(
        properties: [...state.properties, ...newProperties],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newProperties.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger les logements d'un bailleur
  Future<void> loadLandlordProperties(String landlordId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final properties = await _repository.getLandlordProperties(landlordId);
      state = state.copyWith(
        landlordProperties: properties,
        isLoading: false,
        hasAttemptedLandlordFetch: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedLandlordFetch: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger un logement par son ID
  Future<void> loadPropertyById(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final property = await _repository.getPropertyById(id);
      state = state.copyWith(
        selectedProperty: property,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Rechercher des logements
  Future<void> searchProperties({
    String? city,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    bool? furnished,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final properties = await _repository.searchProperties(
        city: city,
        propertyType: propertyType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        furnished: furnished,
      );
      state = state.copyWith(
        properties: properties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Créer un nouveau logement
  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newProperty = await _repository.createProperty(data);
      state = state.copyWith(
        properties: [...state.properties, newProperty],
        landlordProperties: [...state.landlordProperties, newProperty],
        isLoading: false,
      );
      return newProperty;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Mettre à jour un logement
  Future<void> updateProperty(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedProperty = await _repository.updateProperty(id, data);
      
      final updatedProperties = state.properties.map((p) {
        return p.id == id ? updatedProperty : p;
      }).toList();
      
      final updatedLandlordProperties = state.landlordProperties.map((p) {
        return p.id == id ? updatedProperty : p;
      }).toList();
      
      state = state.copyWith(
        properties: updatedProperties,
        landlordProperties: updatedLandlordProperties,
        selectedProperty: state.selectedProperty?.id == id 
            ? updatedProperty 
            : state.selectedProperty,
        isLoading: false,
      );
      
      // Recharger les propriétés du bailleur pour s'assurer que les données sont à jour
      if (updatedLandlordProperties.isNotEmpty) {
        final landlordId = updatedLandlordProperties.first.landlordId;
        if (landlordId != null) {
          await loadLandlordProperties(landlordId);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Supprimer un logement
  Future<void> deleteProperty(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteProperty(id);
      
      final updatedProperties = state.properties.where((p) => p.id != id).toList();
      final updatedLandlordProperties = state.landlordProperties.where((p) => p.id != id).toList();
      
      state = state.copyWith(
        properties: updatedProperties,
        landlordProperties: updatedLandlordProperties,
        selectedProperty: state.selectedProperty?.id == id ? null : state.selectedProperty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Basculer le statut favori avec persistance API
  Future<void> toggleFavorite(String propertyId) async {
    // Trouver la propriété dans toutes les listes
    PropertyModel? target;
    
    try {
      target = state.properties.firstWhere((p) => p.id == propertyId);
    } catch (_) {
      try {
        target = state.favoriteProperties.firstWhere((p) => p.id == propertyId);
      } catch (_) {
        try {
          target = state.landlordProperties.firstWhere((p) => p.id == propertyId);
        } catch (_) {
          // Propriété non trouvée, créer un placeholder
          target = PropertyModel(
            id: propertyId,
            title: '',
            description: '',
            propertyType: '',
            status: '',
            rentPrice: 0,
            surface: 0,
            rooms: 0,
            bedrooms: 0,
            bathrooms: 0,
            furnished: false,
            parking: false,
            balcony: false,
            terrace: false,
            elevator: false,
            garden: false,
            pool: false,
            airConditioning: false,
            heating: '',
            landlordName: '',
            landlordEmail: '',
            landlordStatus: '',
            landlordIsVerified: false,
            viewsCount: 0,
            inquiriesCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isFavorite: false,
          );
        }
      }
    }

    final newIsFavorite = !target.isFavorite;

    // Mise à jour optimiste de l'état local
    final updatedProperties = state.properties.map((p) {
      return p.id == propertyId ? p.copyWith(isFavorite: newIsFavorite) : p;
    }).toList();

    final updatedLandlordProperties = state.landlordProperties.map((p) {
      return p.id == propertyId ? p.copyWith(isFavorite: newIsFavorite) : p;
    }).toList();

    List<PropertyModel> updatedFavorites = List.from(state.favoriteProperties);
    if (newIsFavorite) {
      if (!updatedFavorites.any((p) => p.id == propertyId)) {
        updatedFavorites.add(target.copyWith(isFavorite: true));
      }
    } else {
      updatedFavorites.removeWhere((p) => p.id == propertyId);
    }

    state = state.copyWith(
      properties: updatedProperties,
      landlordProperties: updatedLandlordProperties,
      favoriteProperties: updatedFavorites,
    );

    // Appel API
    bool apiSuccess;
    if (newIsFavorite) {
      apiSuccess = await _repository.addFavorite(propertyId);
    } else {
      apiSuccess = await _repository.removeFavorite(propertyId);
    }

    // Si l'API échoue, revenir à l'état précédent
    if (!apiSuccess) {
      final revertedProperties = state.properties.map((p) {
        return p.id == propertyId ? p.copyWith(isFavorite: !newIsFavorite) : p;
      }).toList();

      final revertedLandlordProperties = state.landlordProperties.map((p) {
        return p.id == propertyId ? p.copyWith(isFavorite: !newIsFavorite) : p;
      }).toList();

      List<PropertyModel> revertedFavorites = List.from(state.favoriteProperties);
      if (!newIsFavorite) {
        if (!revertedFavorites.any((p) => p.id == propertyId)) {
          revertedFavorites.add(target.copyWith(isFavorite: true));
        }
      } else {
        revertedFavorites.removeWhere((p) => p.id == propertyId);
      }

      state = state.copyWith(
        properties: revertedProperties,
        landlordProperties: revertedLandlordProperties,
        favoriteProperties: revertedFavorites,
      );
    }
  }

  /// Sélectionner un logement
  void selectProperty(PropertyModel? property) {
    state = state.copyWith(selectedProperty: property);
  }

  /// Réinitialiser l'état
  void resetState() {
    state = const PropertyState();
  }

  /// Effacer les messages d'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
