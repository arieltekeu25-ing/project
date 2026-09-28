/// Validateur pour les noms et prénoms
class NomValidator {
  /// Longueur minimale
  static const int minLength = 2;
  
  /// Longueur maximale
  static const int maxLength = 50;

  /// Expression régulière pour valider un nom (lettres, accents et tirets autorisés)
  static final RegExp _nomRegExp = RegExp(
    r'^[a-zA-ZàáâäãåāăąçćčđďèéêëēėęěğǵḧîïíīįìłḿñńǹňôöòóœøōõṕŕřßśšşșťțûüùúūǘůűųẃẍÿýžźżÀÁÂÄÃÅĀĂĄÇĆČĐĎÈÉÊËĒĖĘĚĞǴḦÎÏÍĪĮÌŁḾÑŃǸŇÔÖÒÓŒØŌÕṔŔŘßŚŠŞȘŤȚÛÜÙÚŪǗŮŰŲẂẌŸÝŽŹŻ\- ]+$',
  );

  /// Valide un nom ou prénom
  /// Retourne null si valide, sinon un message d'erreur
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    if (value.length < minLength) {
      return 'Doit contenir au moins $minLength caractères';
    }

    if (value.length > maxLength) {
      return 'Ne doit pas dépasser $maxLength caractères';
    }

    if (!_nomRegExp.hasMatch(value)) {
      return 'Format invalide (lettres et tirets uniquement)';
    }

    return null;
  }

  /// Vérifie si le nom est valide sans retourner de message
  static bool isValid(String nom) {
    return validate(nom) == null;
  }
}
