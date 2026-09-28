import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_utilisateur_model.dart';

/// Provider pour la session utilisateur active
final sessionProvider = StateProvider<SessionUtilisateurModel?>((ref) => null);

/// Provider pour le statut de la session
final sessionStatusProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session?.estActive ?? false;
});
