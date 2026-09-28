/// Validateur pour les codes OTP
class OtpValidator {
  /// Longueur par défaut du code OTP
  static const int defaultLength = 6;

  /// Expression régulière pour valider un code OTP (chiffres uniquement)
  static final RegExp _otpRegExp = RegExp(r'^[0-9]+$');

  /// Valide un code OTP
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value, {int length = defaultLength}) {
    if (value == null || value.isEmpty) {
      return 'Le code OTP est requis';
    }

    if (value.length != length) {
      return 'Le code doit contenir $length chiffres';
    }

    if (!_otpRegExp.hasMatch(value)) {
      return 'Le code ne doit contenir que des chiffres';
    }

    return null;
  }

  /// Vérifie si le code OTP est valide sans retourner de message
  static bool isValid(String otp, {int length = defaultLength}) {
    return validate(otp, length: length) == null;
  }
}
