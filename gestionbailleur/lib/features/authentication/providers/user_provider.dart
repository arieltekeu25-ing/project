import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/utilisateur_model.dart';

/// Provider pour l'utilisateur connecté
final userProvider = StateProvider<UtilisateurModel?>((ref) => null);

/// Provider pour le statut de vérification de l'utilisateur
final userVerificationProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user?.estVerifie ?? false;
});
