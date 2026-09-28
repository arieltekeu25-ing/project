import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/models/property_model.dart';
import '../repositories/favorites_repository.dart';
import '../../authentication/providers/auth_provider.dart';

/// État du système de favoris
class FavoritesState {
  final List<PropertyModel> favorites;
  final Set<String> favoriteIds;
  final bool isLoading;
  final bool hasAttemptedFetch;
  final String? errorMessage;
  final String? actionPropertyIdLoading;

  const FavoritesState({
    this.favorites = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
    this.hasAttemptedFetch = false,
    this.errorMessage,
    this.actionPropertyIdLoading,
  });

  FavoritesState copyWith({
    List<PropertyModel>? favorites,
    Set<String>? favoriteIds,
    bool? isLoading,
    bool? hasAttemptedFetch,
    String? errorMessage,
    String? actionPropertyIdLoading,
    bool clearActionLoading = false,
    bool clearError = false,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionPropertyIdLoading: clearActionLoading
          ? null
          : (actionPropertyIdLoading ?? this.actionPropertyIdLoading),
    );
  }
}

/// Provider du repository de favoris
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Provider global pour l'état des favoris (ViewModel)
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repository, ref);
});

/// Notifier ViewModel gérant le système de favoris
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepository _repository;
  final Ref _ref;

  FavoritesNotifier(this._repository, this._ref) : super(const FavoritesState());

  /// Charger les favoris réels de l'utilisateur connecté depuis le backend
  Future<void> loadFavorites({bool forceRefresh = false}) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) {
      state = state.copyWith(
        favorites: [],
        favoriteIds: {},
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
      return;
    }

    if (!forceRefresh && state.hasAttemptedFetch && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final properties = await _repository.getFavorites();
      final ids = properties.map((p) => p.id).toSet();

      state = state.copyWith(
        favorites: properties,
        favoriteIds: ids,
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  /// Basculer l'état favori d'un logement (Ajout / Retrait)
  Future<bool> toggleFavorite({
    required PropertyModel property,
    required BuildContext context,
  }) async {
    final authState = _ref.read(authProvider);

    // RÈGLE Visiteur non connecté
    if (!authState.estAuthentifie) {
      _showLoginRequiredSnackbar(context);
      return false;
    }

    final isCurrentlyFavorite = isFavorite(property.id);

    state = state.copyWith(
      actionPropertyIdLoading: property.id,
      clearError: true,
    );

    try {
      if (isCurrentlyFavorite) {
        // Retirer des favoris
        final success = await _repository.removeFavorite(property.id);
        if (success) {
          final updatedList =
              state.favorites.where((p) => p.id != property.id).toList();
          final updatedIds = Set<String>.from(state.favoriteIds)
            ..remove(property.id);

          state = state.copyWith(
            favorites: updatedList,
            favoriteIds: updatedIds,
            clearActionLoading: true,
          );
          return true;
        }
      } else {
        // Ajouter aux favoris
        final success = await _repository.addFavorite(property.id);
        if (success) {
          final updatedProp = property.copyWith(isFavorite: true);
          final updatedList = List<PropertyModel>.from(state.favorites)
            ..add(updatedProp);
          final updatedIds = Set<String>.from(state.favoriteIds)
            ..add(property.id);

          state = state.copyWith(
            favorites: updatedList,
            favoriteIds: updatedIds,
            clearActionLoading: true,
          );
          return true;
        }
      }
    } catch (e) {
      state = state.copyWith(
        clearActionLoading: true,
        errorMessage: _cleanErrorMessage(e),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_cleanErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    state = state.copyWith(clearActionLoading: true);
    return false;
  }

  /// Retirer un logement directement par son ID (utilisé sur la page favoris)
  Future<bool> removeFavorite(String propertyId, BuildContext context) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) {
      _showLoginRequiredSnackbar(context);
      return false;
    }

    state = state.copyWith(
      actionPropertyIdLoading: propertyId,
      clearError: true,
    );

    try {
      final success = await _repository.removeFavorite(propertyId);
      if (success) {
        final updatedList =
            state.favorites.where((p) => p.id != propertyId).toList();
        final updatedIds = Set<String>.from(state.favoriteIds)
          ..remove(propertyId);

        state = state.copyWith(
          favorites: updatedList,
          favoriteIds: updatedIds,
          clearActionLoading: true,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        clearActionLoading: true,
        errorMessage: _cleanErrorMessage(e),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_cleanErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    state = state.copyWith(clearActionLoading: true);
    return false;
  }

  /// Vérifier si un logement est en favori
  bool isFavorite(String propertyId) {
    return state.favoriteIds.contains(propertyId);
  }

  /// Nombre réel de favoris
  int get favoritesCount => state.favorites.length;

  /// Message clair d'invitation à la connexion
  void _showLoginRequiredSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Connectez-vous pour ajouter des logements à vos favoris.',
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Se connecter',
          textColor: Colors.amber,
          onPressed: () {
            context.go(AppConstants.routeLogin);
          },
        ),
      ),
    );
  }

  /// Helper pour nettoyer les messages d'erreur techniques
  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('Non autorisé') || str.contains('Unauthorized')) {
      return 'Veuillez vous connecter pour gérer vos favoris.';
    }
    if (str.contains('SocketException') || str.contains('NetworkException')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion internet.';
    }
    return 'Une erreur est survenue lors de la mise à jour des favoris.';
  }
}
