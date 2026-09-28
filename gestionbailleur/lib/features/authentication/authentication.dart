// Module d'authentification
// Ce module contient toute l'architecture nécessaire pour gérer l'authentification
// des utilisateurs dans l'application.

// Modèles
export 'models/utilisateur_model.dart';
export 'models/client_model.dart';
export 'models/bailleur_model.dart';
export 'models/administrateur_model.dart';
export 'models/session_utilisateur_model.dart';
export 'models/etat_authentification.dart';

// Enums
export 'models/enums/role_utilisateur.dart';
export 'models/enums/type_connexion.dart';
export 'models/enums/statut_compte.dart';
export 'models/enums/sexe.dart';
export 'models/enums/langue.dart';

// Validateurs
export 'validators/email_validator.dart';
export 'validators/mot_de_passe_validator.dart';
export 'validators/telephone_validator.dart';
export 'validators/nom_validator.dart';
export 'validators/otp_validator.dart';
export 'validators/adresse_validator.dart';
export 'validators/ville_validator.dart';
export 'validators/quartier_validator.dart';

// Services (interfaces)
export 'services/auth_service.dart';
export 'services/session_service.dart';
export 'services/token_service.dart';
export 'services/user_service.dart';
export 'services/storage_service.dart';

// Repositories (interfaces)
export 'repositories/auth_repository.dart';
export 'repositories/session_repository.dart';
export 'repositories/user_repository.dart';

// Providers
export 'providers/auth_provider.dart';
export 'providers/session_provider.dart';
export 'providers/user_provider.dart';

// États
export 'state/auth_state.dart';

// Exceptions
export 'exceptions/email_invalide_exception.dart';
export 'exceptions/mot_de_passe_invalide_exception.dart';
export 'exceptions/compte_bloque_exception.dart';
export 'exceptions/compte_non_valide_exception.dart';
export 'exceptions/session_expiree_exception.dart';
export 'exceptions/erreur_serveur_exception.dart';

// Routes
export 'routes/auth_routes.dart';
export 'routes/route_guard.dart';
export 'routes/route_arguments.dart';
