import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/visite.dart';
import '../repositories/visit_repository.dart';

/// État du provider de visites
class VisitState {
  final List<Visite> myVisits;
  final List<Visite> landlordVisits;
  final Visite? selectedVisit;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasAttemptedFetch;
  final String? errorMessage;

  const VisitState({
    this.myVisits = const [],
    this.landlordVisits = const [],
    this.selectedVisit,
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasAttemptedFetch = false,
    this.errorMessage,
  });

  VisitState copyWith({
    List<Visite>? myVisits,
    List<Visite>? landlordVisits,
    Visite? selectedVisit,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasAttemptedFetch,
    String? errorMessage,
  }) {
    return VisitState(
      myVisits: myVisits ?? this.myVisits,
      landlordVisits: landlordVisits ?? this.landlordVisits,
      selectedVisit: selectedVisit ?? this.selectedVisit,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
      errorMessage: errorMessage,
    );
  }
}

/// Provider du repository de visites
final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return VisitRepository();
});

/// Provider pour l'état des visites du client
final visitProvider = StateNotifierProvider<VisitNotifier, VisitState>(
  (ref) => VisitNotifier(ref.read(visitRepositoryProvider)),
);

/// Notifier pour la gestion des visites
class VisitNotifier extends StateNotifier<VisitState> {
  final VisitRepository _repository;

  VisitNotifier(this._repository) : super(const VisitState());

  /// Charger les visites du client
  Future<void> loadMyVisits({bool refresh = false}) async {
    if (!refresh && state.hasAttemptedFetch) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final visits = await _repository.getMyVisits();
      state = state.copyWith(
        myVisits: visits,
        isLoading: false,
        hasAttemptedFetch: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger les visites reçues par le bailleur
  Future<void> loadLandlordVisits({bool refresh = false}) async {
    if (!refresh && state.hasAttemptedFetch) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final visits = await _repository.getLandlordVisits();
      state = state.copyWith(
        landlordVisits: visits,
        isLoading: false,
        hasAttemptedFetch: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger les détails d'une visite
  Future<void> loadVisitDetail(String visitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final visit = await _repository.getVisitDetail(visitId);
      state = state.copyWith(
        selectedVisit: visit,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Créer une demande de visite
  Future<bool> createVisit({
    required String propertyId,
    required DateTime requestedDate,
    required String requestedTime,
    String? message,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final visit = await _repository.createVisit(
        propertyId: propertyId,
        requestedDate: requestedDate,
        requestedTime: requestedTime,
        message: message,
      );

      // Add to my visits list
      final updatedVisits = [visit, ...state.myVisits];
      state = state.copyWith(
        myVisits: updatedVisits,
        selectedVisit: visit,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Mettre à jour une visite (accepter, refuser, reprogrammer)
  Future<bool> updateVisit({
    required String visitId,
    String? status,
    String? landlordResponse,
    DateTime? rescheduledDate,
    String? rescheduledTime,
    String? rescheduledMessage,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final updatedVisit = await _repository.updateVisit(
        visitId: visitId,
        status: status,
        landlordResponse: landlordResponse,
        rescheduledDate: rescheduledDate,
        rescheduledTime: rescheduledTime,
        rescheduledMessage: rescheduledMessage,
      );

      // Update in landlord visits list
      final updatedLandlordVisits = state.landlordVisits.map((v) {
        return v.id == visitId ? updatedVisit : v;
      }).toList();

      // Update in my visits list if present
      final updatedMyVisits = state.myVisits.map((v) {
        return v.id == visitId ? updatedVisit : v;
      }).toList();

      state = state.copyWith(
        landlordVisits: updatedLandlordVisits,
        myVisits: updatedMyVisits,
        selectedVisit: updatedVisit,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Annuler une visite
  Future<bool> cancelVisit(String visitId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final cancelledVisit = await _repository.cancelVisit(visitId);

      // Update in my visits list
      final updatedMyVisits = state.myVisits.map((v) {
        return v.id == visitId ? cancelledVisit : v;
      }).toList();

      // Update in landlord visits list if present
      final updatedLandlordVisits = state.landlordVisits.map((v) {
        return v.id == visitId ? cancelledVisit : v;
      }).toList();

      state = state.copyWith(
        myVisits: updatedMyVisits,
        landlordVisits: updatedLandlordVisits,
        selectedVisit: cancelledVisit,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Supprimer une demande de visite
  Future<bool> deleteVisit(String visitId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final success = await _repository.deleteVisit(visitId);
      if (success) {
        final updatedLandlordVisits = state.landlordVisits.where((v) => v.id != visitId).toList();
        final updatedMyVisits = state.myVisits.where((v) => v.id != visitId).toList();
        state = state.copyWith(
          landlordVisits: updatedLandlordVisits,
          myVisits: updatedMyVisits,
          isSubmitting: false,
        );
      } else {
        state = state.copyWith(isSubmitting: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Accepter une proposition de reprogrammation
  Future<bool> acceptReschedule(String visitId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final updatedVisit = await _repository.acceptReschedule(visitId);

      // Update in my visits list
      final updatedMyVisits = state.myVisits.map((v) {
        return v.id == visitId ? updatedVisit : v;
      }).toList();

      // Update in landlord visits list if present
      final updatedLandlordVisits = state.landlordVisits.map((v) {
        return v.id == visitId ? updatedVisit : v;
      }).toList();

      state = state.copyWith(
        myVisits: updatedMyVisits,
        landlordVisits: updatedLandlordVisits,
        selectedVisit: updatedVisit,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const VisitState();
  }

  /// Effacer le message d'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
