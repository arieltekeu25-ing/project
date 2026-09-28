/// Utilitaires de validation
class Validators {
  /// Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valider un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  /// Valider la confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Valider un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Valider un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Valider un champ requis
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }
}
