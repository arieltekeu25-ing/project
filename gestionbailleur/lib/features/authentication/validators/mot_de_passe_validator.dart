/// Validateur pour les mots de passe
class MotDePasseValidator {
  /// Longueur minimale du mot de passe
  static const int minLength = 8;
  
  /// Longueur maximale du mot de passe
  static const int maxLength = 128;

  /// Valide un mot de passe
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'Le mot de passe ne doit pas dépasser $maxLength caractères';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
  }

  /// Vérifie si le mot de passe est valide sans retourner de message
  static bool isValid(String password) {
    return validate(password) == null;
  }

  /// Valide la confirmation du mot de passe
  static String? validateConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (password != confirmation) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }
}
