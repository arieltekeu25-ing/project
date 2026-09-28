/// Validateur pour les quartiers
class QuartierValidator {
  /// Longueur minimale
  static const int minLength = 2;
  
  /// Longueur maximale
  static const int maxLength = 100;

  /// Expression régulière pour valider un nom de quartier
  static final RegExp _quartierRegExp = RegExp(
    r'^[a-zA-ZàáâäãåāăąçćčđďèéêëēėęěğǵḧîïíīįìłḿñńǹňôöòóœøōõṕŕřßśšşșťțûüùúūǘůűųẃẍÿýžźżÀÁÂÄÃÅĀĂĄÇĆČĐĎÈÉÊËĒĖĘĚĞǴḦÎÏÍĪĮÌŁḾÑŃǸŇÔÖÒÓŒØŌÕṔŔŘßŚŠŞȘŤȚÛÜÙÚŪǗŮŰŲẂẌŸÝŽŹŻ\- ]+$',
  );

  /// Valide un nom de quartier
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le quartier est requis';
    }

    if (value.length < minLength) {
      return 'Le quartier doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'Le quartier ne doit pas dépasser $maxLength caractères';
    }

    if (!_quartierRegExp.hasMatch(value)) {
      return 'Format de quartier invalide';
    }

    return null;
  }

  /// Vérifie si le quartier est valide sans retourner de message
  static bool isValid(String quartier) {
    return validate(quartier) == null;
  }
}
