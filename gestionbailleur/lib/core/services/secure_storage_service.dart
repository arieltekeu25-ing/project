import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé pour les tokens et données sensibles
class SecureStorageService {
  static SecureStorageService? _instance;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  SecureStorageService._();

  /// Instance singleton
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  /// Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _roleCodeKey = 'role_code';

  /// Sauvegarder le token d'accès
  Future<bool> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarder le refresh token
  Future<bool> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarder l'ID utilisateur
  Future<bool> setUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarder le code du rôle
  Future<bool> setRoleCode(String roleCode) async {
    try {
      await _storage.write(key: _roleCodeKey, value: roleCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer le code du rôle
  Future<String?> getRoleCode() async {
    try {
      return await _storage.read(key: _roleCodeKey);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer tous les tokens
  Future<bool> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _roleCodeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
