import 'package:flutter/material.dart';

/// Extensions sur BuildContext
extension ContextExtensions on BuildContext {
  /// Obtenir le thème
  ThemeData get theme => Theme.of(this);

  /// Obtenir le schéma de couleurs
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Obtenir le thème de texte
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Naviguer vers une route
  void navigateTo(String route) {
    Navigator.pushNamed(this, route);
  }

  /// Remplacer la route actuelle
  void navigateAndReplace(String route) {
    Navigator.pushReplacementNamed(this, route);
  }

  /// Retourner à l'écran précédent
  void goBack<T>([T? result]) {
    Navigator.pop(this, result);
  }

  /// Afficher un snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Afficher un dialogue de chargement
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Masquer le dialogue de chargement
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  /// Afficher un dialogue de confirmation
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
