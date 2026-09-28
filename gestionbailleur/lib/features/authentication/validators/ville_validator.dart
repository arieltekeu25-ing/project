/// Validateur pour les villes
class VilleValidator {
  /// Longueur minimale
  static const int minLength = 2;
  
  /// Longueur maximale
  static const int maxLength = 100;

  /// Expression régulière pour valider un nom de ville
  static final RegExp _villeRegExp = RegExp(
    r'^[a-zA-ZàáâäãåāăąçćčđďèéêëēėęěğǵḧîïíīįìłḿñńǹňôöòóœøōõṕŕřßśšşșťțûüùúūǘůűųẃẍÿýžźżÀÁÂÄÃÅĀĂĄÇĆČĐĎÈÉÊËĒĖĘĚĞǴḦÎÏÍĪĮÌŁḾÑŃǸŇÔÖÒÓŒØŌÕṔŔŘßŚŠŞȘŤȚÛÜÙÚŪǗŮŰŲẂẌŸÝŽŹŻ\- ]+$',
  );

  /// Valide un nom de ville
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La ville est requise';
    }

    if (value.length < minLength) {
      return 'La ville doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'La ville ne doit pas dépasser $maxLength caractères';
    }

    if (!_villeRegExp.hasMatch(value)) {
      return 'Format de ville invalide';
    }

    return null;
  }

  /// Vérifie si la ville est valide sans retourner de message
  static bool isValid(String ville) {
    return validate(ville) == null;
  }
}
