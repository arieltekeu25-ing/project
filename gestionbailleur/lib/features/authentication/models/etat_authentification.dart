import 'utilisateur_model.dart';
import 'session_utilisateur_model.dart';

/// État global de l'authentification dans l'application
class EtatAuthentification {
  final bool estAuthentifie;
  final bool estChargement;
  final UtilisateurModel? utilisateur;
  final SessionUtilisateurModel? session;
  final String? messageErreur;
  final String? codeErreur;

  EtatAuthentification({
    this.estAuthentifie = false,
    this.estChargement = false,
    this.utilisateur,
    this.session,
    this.messageErreur,
    this.codeErreur,
  });

  /// État initial (non authentifié)
  factory EtatAuthentification.initial() {
    return EtatAuthentification();
  }

  /// État de chargement
  factory EtatAuthentification.chargement({String? message}) {
    return EtatAuthentification(
      estChargement: true,
      messageErreur: message,
    );
  }

  /// État authentifié avec utilisateur et session
  factory EtatAuthentification.authentifie({
    required UtilisateurModel utilisateur,
    required SessionUtilisateurModel session,
  }) {
    return EtatAuthentification(
      estAuthentifie: true,
      utilisateur: utilisateur,
      session: session,
    );
  }

  /// État non authentifié
  factory EtatAuthentification.nonAuthentifie() {
    return EtatAuthentification(
      estAuthentifie: false,
    );
  }

  /// État avec erreur
  factory EtatAuthentification.erreur({
    required String message,
    String? code,
  }) {
    return EtatAuthentification(
      estAuthentifie: false,
      messageErreur: message,
      codeErreur: code,
    );
  }

  /// État déconnecté
  factory EtatAuthentification.deconnecte() {
    return EtatAuthentification(
      estAuthentifie: false,
      utilisateur: null,
      session: null,
    );
  }

  EtatAuthentification copyWith({
    bool? estAuthentifie,
    bool? estChargement,
    UtilisateurModel? utilisateur,
    SessionUtilisateurModel? session,
    String? messageErreur,
    String? codeErreur,
  }) {
    return EtatAuthentification(
      estAuthentifie: estAuthentifie ?? this.estAuthentifie,
      estChargement: estChargement ?? this.estChargement,
      utilisateur: utilisateur ?? this.utilisateur,
      session: session ?? this.session,
      messageErreur: messageErreur ?? this.messageErreur,
      codeErreur: codeErreur ?? this.codeErreur,
    );
  }
}

/// Type alias pour l'état authentifié
typedef EtatAuthentificationAuthentifie = EtatAuthentification;
