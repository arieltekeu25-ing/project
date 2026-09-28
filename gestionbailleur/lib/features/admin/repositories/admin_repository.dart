import '../../../core/services/api_service.dart';
import '../models/admin_user_model.dart';

/// Repository pour les opérations admin sur les utilisateurs
class AdminRepository {
  final ApiService _apiService;

  AdminRepository({
    required ApiService apiService,
  })  : _apiService = apiService;

  /// Récupérer tous les utilisateurs
  Future<List<AdminUserModel>> getUsers({
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '/api/v1/auth/admin/users/',
        queryParams: queryParams,
      );

      if (response is List) {
        return response.map((json) => AdminUserModel.fromJson(json)).toList();
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Récupérer les détails d'un utilisateur
  Future<AdminUserModel> getUserDetails(String userId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/auth/admin/users/$userId/',
      );

      return AdminUserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour un utilisateur
  Future<AdminUserModel> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        '/api/v1/auth/admin/users/$userId/update/',
        body: data,
      );

      return AdminUserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour le statut d'un utilisateur
  Future<AdminUserModel> updateUserStatus(
    String userId,
    String status, {
    String? reason,
  }) async {
    try {
      final data = {'etat_compte': status};
      if (reason != null) data['reason'] = reason;

      final response = await _apiService.post(
        '/api/v1/auth/admin/users/$userId/status/',
        body: data,
      );

      return AdminUserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour le rôle d'un utilisateur
  Future<AdminUserModel> updateUserRole(String userId, String roleCode) async {
    try {
      final response = await _apiService.post(
        '/api/v1/auth/admin/users/$userId/role/',
        body: {'role_code': roleCode},
      );

      return AdminUserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete(
        '/api/v1/auth/admin/users/$userId/delete/',
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
