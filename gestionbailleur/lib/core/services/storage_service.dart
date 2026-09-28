import 'package:shared_preferences/shared_preferences.dart';

/// Service de stockage local
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _preferences;

  StorageService._();

  /// Instance singleton
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialisation
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Sauvegarder une chaîne de caractères
  Future<bool> setString(String key, String value) async {
    return _preferences?.setString(key, value) ?? false;
  }

  /// Récupérer une chaîne de caractères
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  /// Sauvegarder un entier
  Future<bool> setInt(String key, int value) async {
    return _preferences?.setInt(key, value) ?? false;
  }

  /// Récupérer un entier
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  /// Sauvegarder un booléen
  Future<bool> setBool(String key, bool value) async {
    return _preferences?.setBool(key, value) ?? false;
  }

  /// Récupérer un booléen
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  /// Sauvegarder un double
  Future<bool> setDouble(String key, double value) async {
    return _preferences?.setDouble(key, value) ?? false;
  }

  /// Récupérer un double
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  /// Sauvegarder une liste de chaînes
  Future<bool> setStringList(String key, List<String> value) async {
    return _preferences?.setStringList(key, value) ?? false;
  }

  /// Récupérer une liste de chaînes
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  /// Supprimer une clé
  Future<bool> remove(String key) async {
    return _preferences?.remove(key) ?? false;
  }

  /// Vider tout le stockage
  Future<bool> clear() async {
    return _preferences?.clear() ?? false;
  }

  /// Vérifier si une clé existe
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }
}
