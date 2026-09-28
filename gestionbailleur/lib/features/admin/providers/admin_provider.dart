import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user_model.dart';
import '../repositories/admin_repository.dart';
import '../../../core/providers/service_providers.dart';

/// État de l'administration
enum AdminState {
  initial,
  loading,
  loaded,
  error,
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(AdminState.initial);

  List<AdminUserModel> _users = [];
  String _selectedFilter = 'all';
  String? _errorMessage;

  List<AdminUserModel> get users => _filteredUsers;
  String get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;

  List<AdminUserModel> get _filteredUsers {
    if (_selectedFilter == 'all') return _users;
    if (_selectedFilter == 'clients') {
      return _users.where((u) => u.roleCode == 'CLIENT').toList();
    }
    if (_selectedFilter == 'landlords') {
      return _users.where((u) => u.roleCode == 'BAILLEUR').toList();
    }
    if (_selectedFilter == 'pending') {
      return _users.where((u) => u.etatCompte == 'EN_ATTENTE').toList();
    }
    if (_selectedFilter == 'blocked') {
      return _users.where((u) => u.etatCompte == 'BLOQUE').toList();
    }
    return _users;
  }

  /// Charger tous les utilisateurs
  Future<void> loadUsers({
    String? role,
    String? status,
    String? search,
  }) async {
    state = AdminState.loading;
    _errorMessage = null;

    try {
      _users = await _repository.getUsers(
        role: role,
        status: status,
        search: search,
      );
      state = AdminState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      state = AdminState.error;
    }
  }

  /// Changer le filtre
  void setFilter(String filter) {
    _selectedFilter = filter;
    state = state; // Trigger rebuild
  }

  /// Mettre à jour le statut d'un utilisateur
  Future<void> updateUserStatus(String userId, String status, {String? reason}) async {
    try {
      final updatedUser = await _repository.updateUserStatus(userId, status, reason: reason);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        state = state; // Trigger rebuild
      }
    } catch (e) {
      _errorMessage = e.toString();
      state = AdminState.error;
    }
  }

  /// Approuver un compte bailleur
  Future<void> approveLandlord(String userId) async {
    await updateUserStatus(userId, 'ACTIF', reason: 'Compte approuvé par l\'administrateur');
  }

  /// Rejeter un compte bailleur
  Future<void> rejectLandlord(String userId, {String? reason}) async {
    await updateUserStatus(userId, 'BLOQUE', reason: reason ?? 'Compte rejeté par l\'administrateur');
  }

  /// Désactiver un compte utilisateur
  Future<void> deactivateUser(String userId, {String? reason}) async {
    await updateUserStatus(userId, 'INACTIF', reason: reason ?? 'Compte désactivé par l\'administrateur');
  }

  /// Activer un compte utilisateur
  Future<void> activateUser(String userId) async {
    await updateUserStatus(userId, 'ACTIF', reason: 'Compte réactivé par l\'administrateur');
  }

  /// Bloquer un compte utilisateur
  Future<void> blockUser(String userId, {String? reason}) async {
    await updateUserStatus(userId, 'BLOQUE', reason: reason ?? 'Compte bloqué par l\'administrateur');
  }

  /// Mettre à jour le rôle d'un utilisateur
  Future<void> updateUserRole(String userId, String roleCode) async {
    try {
      final updatedUser = await _repository.updateUserRole(userId, roleCode);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        state = state; // Trigger rebuild
      }
    } catch (e) {
      _errorMessage = e.toString();
      state = AdminState.error;
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _repository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      state = state; // Trigger rebuild
    } catch (e) {
      _errorMessage = e.toString();
      state = AdminState.error;
    }
  }

  /// Réinitialiser l'état
  void reset() {
    _users = [];
    _selectedFilter = 'all';
    _errorMessage = null;
    state = AdminState.initial;
  }
}

/// Provider pour le repository admin
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    apiService: ref.watch(apiServiceProvider),
  );
});

/// Provider pour le notifier admin
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminRepositoryProvider));
});
