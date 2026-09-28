/// Validateur pour les adresses email
class EmailValidator {
  /// Expression régulière pour valider un email
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Valide une adresse email
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    if (!_emailRegExp.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }

  /// Vérifie si l'email est valide sans retourner de message
  static bool isValid(String email) {
    return _emailRegExp.hasMatch(email);
  }
}
