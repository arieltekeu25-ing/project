/// Validateur pour les numéros de téléphone
class TelephoneValidator {
  /// Expression régulière pour valider un numéro de téléphone international
  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  /// Valide un numéro de téléphone
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    final cleanNumber = value.replaceAll(RegExp(r'[\s\-()]'), '');

    if (!_phoneRegExp.hasMatch(cleanNumber)) {
      return 'Format de numéro de téléphone invalide';
    }

    return null;
  }

  /// Vérifie si le numéro de téléphone est valide sans retourner de message
  static bool isValid(String telephone) {
    final cleanNumber = telephone.replaceAll(RegExp(r'[\s\-()]'), '');
    return _phoneRegExp.hasMatch(cleanNumber);
  }

  /// Nettoie un numéro de téléphone (supprime espaces, tirets, parenthèses)
  static String clean(String telephone) {
    return telephone.replaceAll(RegExp(r'[\s\-()]'), '');
  }
}
