/// Interface du service de stockage local
abstract class StorageService {
  /// Stocker une valeur clé-valeur
  Future<void> setString(String key, String value);

  /// Récupérer une valeur par sa clé
  Future<String?> getString(String key);

  /// Stocker un booléen
  Future<void> setBool(String key, bool value);

  /// Récupérer un booléen
  Future<bool?> getBool(String key);

  /// Stocker un entier
  Future<void> setInt(String key, int value);

  /// Récupérer un entier
  Future<int?> getInt(String key);

  /// Stocker un double
  Future<void> setDouble(String key, double value);

  /// Récupérer un double
  Future<double?> getDouble(String key);

  /// Stocker une liste de chaînes
  Future<void> setStringList(String key, List<String> value);

  /// Récupérer une liste de chaînes
  Future<List<String>?> getStringList(String key);

  /// Supprimer une valeur par sa clé
  Future<void> remove(String key);

  /// Vider tout le stockage
  Future<void> clear();

  /// Vérifier si une clé existe
  Future<bool> containsKey(String key);

  /// Récupérer toutes les clés
  Future<List<String>> getAllKeys();
}
