import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache pour stocker les données localement
class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'timestamp_';
  static const int _defaultCacheDuration = 30; // minutes

  static CacheService? _instance;
  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  CacheService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Stocker des données dans le cache
  Future<void> set(String key, dynamic data, {int durationMinutes = _defaultCacheDuration}) async {
    await init();
    final timestamp = DateTime.now().add(Duration(minutes: durationMinutes)).millisecondsSinceEpoch;
    await _prefs!.setString('$_timestampPrefix$key', timestamp.toString());
    await _prefs!.setString('$_cachePrefix$key', jsonEncode(data));
  }

  /// Récupérer des données du cache
  T? get<T>(String key) {
    if (_prefs == null) return null;
    
    final timestampStr = _prefs!.getString('$_timestampPrefix$key');
    if (timestampStr == null) return null;
    
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return null;
    
    // Vérifier si le cache est expiré
    if (DateTime.now().millisecondsSinceEpoch > timestamp) {
      remove(key);
      return null;
    }
    
    final dataStr = _prefs!.getString('$_cachePrefix$key');
    if (dataStr == null) return null;
    
    try {
      return jsonDecode(dataStr) as T;
    } catch (e) {
      return null;
    }
  }

  /// Supprimer une entrée du cache
  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove('$_timestampPrefix$key');
    await _prefs!.remove('$_cachePrefix$key');
  }

  /// Vider tout le cache
  Future<void> clear() async {
    await init();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Vérifier si une clé existe et n'est pas expirée
  bool has(String key) {
    if (_prefs == null) return false;
    
    final timestampStr = _prefs!.getString('$_timestampPrefix$key');
    if (timestampStr == null) return false;
    
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return false;
    
    if (DateTime.now().millisecondsSinceEpoch > timestamp) {
      remove(key);
      return false;
    }
    
    return true;
  }
}
