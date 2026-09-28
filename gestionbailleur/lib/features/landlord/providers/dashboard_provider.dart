import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestionbailleur/core/network/network_exceptions.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../models/dashboard_summary_model.dart';
import '../repositories/dashboard_repository.dart';

/// État global du dashboard du bailleur
class DashboardState {
  final DashboardSummaryModel? summary;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final bool isUnauthorized;
  final bool isForbidden;
  final bool isServerError;
  final bool hasAttemptedFetch;

  const DashboardState({
    this.summary,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.isUnauthorized = false,
    this.isForbidden = false,
    this.isServerError = false,
    this.hasAttemptedFetch = false,
  });

  /// Indique si le dashboard est vide (pas de propriétés ni de visites)
  bool get isEmpty =>
      summary == null || (summary!.properties.isEmpty && summary!.visits.isEmpty);

  DashboardState copyWith({
    DashboardSummaryModel? summary,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool? isUnauthorized,
    bool? isForbidden,
    bool? isServerError,
    bool? hasAttemptedFetch,
    bool clearError = false,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      isForbidden: isForbidden ?? this.isForbidden,
      isServerError: isServerError ?? this.isServerError,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
    );
  }
}

/// Provider pour le DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Provider pour le DashboardNotifier
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository, ref);
});

/// Notifier pour gérer l'état du tableau de bord bailleur
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final Ref _ref;

  DashboardNotifier(this._repository, this._ref) : super(const DashboardState());

  /// Charge les statistiques réelles du dashboard
  Future<void> loadDashboard({bool isRefresh = false}) async {
    final authState = _ref.read(authProvider);
    final user = authState.utilisateur;

    // 1. Vérification d'authentification
    if (!authState.estAuthentifie || user == null) {
      state = state.copyWith(
        isUnauthorized: true,
        isLoading: false,
        isRefreshing: false,
        hasAttemptedFetch: true,
      );
      return;
    }

    // 2. Vérification de rôle - restaurée pour la sécurité
    if (user.role != RoleUtilisateur.bailleur) {
      state = state.copyWith(
        isForbidden: true,
        isLoading: false,
        isRefreshing: false,
        hasAttemptedFetch: true,
      );
      return;
    }

    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, errorMessage: null, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    }

    try {
      final summary = await _repository.getDashboardSummary(user.id);
      state = state.copyWith(
        summary: summary,
        isLoading: false,
        isRefreshing: false,
        isUnauthorized: false,
        isForbidden: false,
        isServerError: false,
        hasAttemptedFetch: true,
      );
    } catch (e) {
      bool serverError = false;
      bool unauthorized = false;
      bool forbidden = false;
      String message = e.toString();

      if (e is ForbiddenException) {
        forbidden = true;
        message = 'Accès interdit au tableau de bord bailleur.';
      } else if (e is UnauthorizedException) {
        unauthorized = true;
        message = 'Session expirée ou non autorisée.';
      } else if (e is ServerException) {
        serverError = true;
        message = 'Erreur interne du serveur. Veuillez réessayer plus tard.';
      } else if (message.contains('500')) {
        serverError = true;
      }

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isUnauthorized: unauthorized,
        isForbidden: forbidden,
        isServerError: serverError,
        errorMessage: message,
        hasAttemptedFetch: true,
      );
    }
  }

  /// Réinitialise l'état du dashboard (utile lors d'un logout)
  void resetState() {
    state = const DashboardState();
  }
}
