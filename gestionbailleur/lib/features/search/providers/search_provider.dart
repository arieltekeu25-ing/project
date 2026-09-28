import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/cameroon_cities.dart';
import '../../home/models/property_model.dart';
import '../models/search_filter_model.dart';
import '../models/search_options_model.dart';
import '../repositories/search_repository.dart';
import '../services/location_service.dart';

enum SearchViewMode {
  list,
  grid,
  map,
}

class SearchState {
  final SearchFilterModel filters;
  final SearchOptionsModel options;
  final List<PropertyModel> results;
  final bool isLoading;
  final bool isOptionsLoading;
  final String? errorMessage;
  final LocationStatus locationStatus;
  final bool isLocating;
  final SearchViewMode viewMode;
  final bool hasSearched;

  const SearchState({
    this.filters = const SearchFilterModel(),
    this.options = const SearchOptionsModel(),
    this.results = const [],
    this.isLoading = false,
    this.isOptionsLoading = false,
    this.errorMessage,
    this.locationStatus = LocationStatus.unknown,
    this.isLocating = false,
    this.viewMode = SearchViewMode.list,
    this.hasSearched = false,
  });

  SearchState copyWith({
    SearchFilterModel? filters,
    SearchOptionsModel? options,
    List<PropertyModel>? results,
    bool? isLoading,
    bool? isOptionsLoading,
    String? errorMessage,
    LocationStatus? locationStatus,
    bool? isLocating,
    SearchViewMode? viewMode,
    bool? hasSearched,
    bool clearError = false,
  }) {
    return SearchState(
      filters: filters ?? this.filters,
      options: options ?? this.options,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isOptionsLoading: isOptionsLoading ?? this.isOptionsLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      locationStatus: locationStatus ?? this.locationStatus,
      isLocating: isLocating ?? this.isLocating,
      viewMode: viewMode ?? this.viewMode,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;
  final LocationService _locationService = LocationService.instance;
  Timer? _debounceTimer;

  SearchNotifier(this._repository) : super(const SearchState()) {
    init();
  }

  Future<void> init() async {
    await loadFilterOptions();
    await performSearch();
  }

  /// Charger les filtres réels depuis PostgreSQL + villes du Cameroun
  Future<void> loadFilterOptions() async {
    state = state.copyWith(isOptionsLoading: true, clearError: true);
    try {
      final backendOptions = await _repository.getFilterOptions();
      
      // Fusionner avec les villes du Cameroun
      final cameroonCities = CameroonCities.allCities;
      final allCities = {...backendOptions.cities, ...cameroonCities}.toList();
      
      // Si une ville est sélectionnée, mettre à jour les quartiers automatiquement
      List<String> districts = backendOptions.districts;
      if (state.filters.city != null && CameroonCities.citiesAndDistricts.containsKey(state.filters.city)) {
        districts = CameroonCities.getDistricts(state.filters.city!);
      }
      
      final options = SearchOptionsModel(
        cities: allCities,
        districts: districts,
        propertyTypes: backendOptions.propertyTypes,
        minPrice: backendOptions.minPrice,
        maxPrice: backendOptions.maxPrice,
      );
      
      state = state.copyWith(options: options, isOptionsLoading: false);
    } catch (e) {
      // En cas d'erreur backend, utiliser les villes du Cameroun par défaut
      final defaultOptions = SearchOptionsModel(
        cities: CameroonCities.allCities,
        districts: CameroonCities.allDistricts,
        propertyTypes: ['Appartement', 'Studio', 'Villa', 'Maison', 'Bureau', 'Boutique'],
        minPrice: 0.0,
        maxPrice: 10000000.0,
      );
      state = state.copyWith(options: defaultOptions, isOptionsLoading: false);
    }
  }

  /// Effectuer la recherche avec les filtres actuels
  Future<void> performSearch() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await _repository.searchProperties(state.filters);
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasSearched: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasSearched: true,
        results: [], // Retourner une liste vide en cas d'erreur
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  /// Mettre à jour la recherche textuelle avec un debounce de 400ms
  void updateQuery(String query) {
    // Analyser le query pour détecter si c'est une ville ou un quartier
    String? detectedCity;
    String? detectedDistrict;
    String? remainingQuery;

    if (query.trim().isNotEmpty) {
      final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
      
      // Vérifier si le premier mot correspond à une ville connue
      if (words.isNotEmpty) {
        final firstWord = words[0];
        final matchingCity = state.options.cities.firstWhere(
          (city) => city.toLowerCase() == firstWord,
          orElse: () => '',
        );
        
        if (matchingCity.isNotEmpty) {
          detectedCity = matchingCity;
          
          // Vérifier si le deuxième mot correspond à un quartier de cette ville
          if (words.length > 1) {
            final secondWord = words[1];
            final matchingDistrict = state.options.districts.firstWhere(
              (district) => district.toLowerCase() == secondWord,
              orElse: () => '',
            );
            
            if (matchingDistrict.isNotEmpty) {
              detectedDistrict = matchingDistrict;
              remainingQuery = words.length > 2 ? words.sublist(2).join(' ') : null;
            } else {
              remainingQuery = words.sublist(1).join(' ');
            }
          }
        } else {
          remainingQuery = query.trim();
        }
      }
    }

    // Mettre à jour les filtres avec les détectations automatiques
    final newFilters = state.filters.copyWith(
      query: remainingQuery,
      city: detectedCity ?? state.filters.city,
      district: detectedDistrict ?? state.filters.district,
      clearCity: detectedCity == null && query.trim().isEmpty,
      clearDistrict: detectedDistrict == null && query.trim().isEmpty,
    );

    state = state.copyWith(filters: newFilters);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      performSearch();
    });
  }

  /// Appliquer de nouveaux filtres
  void applyFilters(SearchFilterModel newFilters) {
    // Si la ville change, mettre à jour les quartiers automatiquement
    if (newFilters.city != state.filters.city) {
      List<String> newDistricts = state.options.districts;
      if (newFilters.city != null && CameroonCities.citiesAndDistricts.containsKey(newFilters.city)) {
        newDistricts = CameroonCities.getDistricts(newFilters.city!);
      }
      
      state = state.copyWith(
        filters: newFilters,
        options: state.options.copyWith(districts: newDistricts),
      );
    } else {
      state = state.copyWith(filters: newFilters);
    }
    
    // Recherche en temps réel avec debounce
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      performSearch();
    });
  }

  /// Mettre à jour la ville et les quartiers automatiquement
  void updateCity(String? city) {
    List<String> newDistricts = state.options.districts;
    if (city != null && CameroonCities.citiesAndDistricts.containsKey(city)) {
      newDistricts = CameroonCities.getDistricts(city);
    }
    
    final newFilters = state.filters.copyWith(
      city: city,
      district: null, // Réinitialiser le quartier quand la ville change
      clearCity: city == null,
    );
    
    state = state.copyWith(
      filters: newFilters,
      options: state.options.copyWith(districts: newDistricts),
    );
    
    // Recherche en temps réel avec debounce plus court pour villes/quartiers
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      performSearch();
    });
  }

  /// Réinitialiser les filtres
  void resetFilters() {
    state = state.copyWith(
      filters: const SearchFilterModel(),
    );
    performSearch();
  }

  /// Demander la position GPS réelle et lancer la recherche à proximité
  Future<void> requestGPSLocationAndSearch() async {
    state = state.copyWith(isLocating: true);

    final status = await _locationService.requestPermission();
    state = state.copyWith(locationStatus: status);

    if (status != LocationStatus.granted) {
      state = state.copyWith(isLocating: false);
      return;
    }

    final position = await _locationService.getCurrentPosition();
    state = state.copyWith(isLocating: false);

    if (position != null) {
      state = state.copyWith(
        filters: state.filters.copyWith(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          ordering: 'distance',
        ),
      );
      performSearch();
    } else {
      state = state.copyWith(
        errorMessage: 'Impossible de récupérer votre position GPS actuelle.',
      );
    }
  }

  /// Désactiver la géolocalisation
  void clearLocation() {
    state = state.copyWith(
      filters: state.filters.copyWith(
        clearLocation: true,
        ordering: '-created_at',
      ),
    );
    performSearch();
  }

  /// Changer le mode de vue (Liste / Grille / Carte)
  void setViewMode(SearchViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Changer le mode de recherche (Manual, Advanced, AI)
  void setSearchMode(SearchMode mode) {
    state = state.copyWith(
      filters: state.filters.copyWith(mode: mode),
    );
  }

  /// Définir le filtre de type de propriété (pour les catégories)
  void setPropertyTypeFilter(String propertyType) {
    state = state.copyWith(
      filters: state.filters.copyWith(propertyType: propertyType),
    );
    performSearch();
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('SocketException') || str.contains('NetworkException')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion internet.';
    }
    return 'Une erreur est survenue lors de la recherche des logements.';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
