/// Statut du compte utilisateur
enum StatutCompte {
  /// Compte en attente de validation
  enAttente,

  /// Compte actif et validé
  actif,

  /// Compte bloqué temporairement ou définitivement
  bloque,

  /// Compte désactivé par l'utilisateur
  desactive,

  /// Compte en attente de validation bailleur
  enAttenteValidation,
}
