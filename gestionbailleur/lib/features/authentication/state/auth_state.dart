import '../models/utilisateur_model.dart';
import '../models/session_utilisateur_model.dart';

/// État de base pour l'authentification
abstract class AuthState {
  const AuthState();
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État de chargement
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});
}

/// État authentifié
class AuthAuthenticated extends AuthState {
  final UtilisateurModel utilisateur;
  final SessionUtilisateurModel session;

  const AuthAuthenticated({
    required this.utilisateur,
    required this.session,
  });
}

/// État non authentifié
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// État d'erreur
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });
}

/// État de session expirée
class AuthExpired extends AuthState {
  final String? message;

  const AuthExpired({this.message});
}
