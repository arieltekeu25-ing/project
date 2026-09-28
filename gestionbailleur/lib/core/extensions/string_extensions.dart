/// Extensions sur String
extension StringExtensions on String {
  /// Mettre la première lettre en majuscule
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Tronquer le texte avec des points de suspension
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Supprimer les espaces en trop
  String trimAll() {
    return split(' ').where((s) => s.isNotEmpty).join(' ');
  }

  /// Vérifier si c'est un email valide
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Vérifier si c'est un numéro de téléphone valide
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(this);
  }

  /// Vérifier si c'est une URL valide
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }
}
