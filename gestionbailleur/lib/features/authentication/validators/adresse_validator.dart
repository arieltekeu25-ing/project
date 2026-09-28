/// Validateur pour les adresses
class AdresseValidator {
  /// Longueur minimale
  static const int minLength = 5;
  
  /// Longueur maximale
  static const int maxLength = 200;

  /// Valide une adresse
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse est requise';
    }

    if (value.length < minLength) {
      return 'L\'adresse doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'L\'adresse ne doit pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Vérifie si l'adresse est valide sans retourner de message
  static bool isValid(String adresse) {
    return validate(adresse) == null;
  }
}
