import 'package:flutter/material.dart';
import '../buttons/ds_button.dart';
import '../spacing/ds_spacing.dart';
import '../radius/ds_radius.dart';
import '../typography/ds_text_style.dart';

/// Type de dialogue du Design System
enum DSDialogType {
  confirmation,
  error,
  success,
  info,
  delete,
}

/// Dialogue du Design System
class DSDialog {
  /// Afficher un dialogue de confirmation
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return _showDialog(
      context: context,
      type: DSDialogType.confirmation,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  /// Afficher un dialogue d'erreur
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return _showDialog(
      context: context,
      type: DSDialogType.error,
      title: title,
      message: message,
      confirmText: confirmText,
    );
  }

  /// Afficher un dialogue de succès
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return _showDialog(
      context: context,
      type: DSDialogType.success,
      title: title,
      message: message,
      confirmText: confirmText,
    );
  }

  /// Afficher un dialogue d'information
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return _showDialog(
      context: context,
      type: DSDialogType.info,
      title: title,
      message: message,
      confirmText: confirmText,
    );
  }

  /// Afficher un dialogue de suppression
  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Supprimer',
    String cancelText = 'Annuler',
  }) {
    return _showDialog(
      context: context,
      type: DSDialogType.delete,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  static Future<T?> _showDialog<T>({
    required BuildContext context,
    required DSDialogType type,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
  }) {
    final theme = Theme.of(context);

    IconData icon;
    Color iconColor;

    switch (type) {
      case DSDialogType.confirmation:
        icon = Icons.help_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case DSDialogType.error:
        icon = Icons.error_outline;
        iconColor = theme.colorScheme.error;
        break;
      case DSDialogType.success:
        icon = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case DSDialogType.info:
        icon = Icons.info_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case DSDialogType.delete:
        icon = Icons.delete_outline;
        iconColor = theme.colorScheme.error;
        break;
    }

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: DSRadius.lgRadius,
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: DSTextStyle.headlineSmall,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: DSTextStyle.bodyMedium,
        ),
        actions: [
          if (cancelText != null)
            DSButton(
              text: cancelText,
              type: DSButtonType.text,
              onPressed: () => Navigator.pop(context, false),
            ),
          DSButton(
            text: confirmText,
            type: type == DSDialogType.delete
                ? DSButtonType.danger
                : DSButtonType.primary,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
