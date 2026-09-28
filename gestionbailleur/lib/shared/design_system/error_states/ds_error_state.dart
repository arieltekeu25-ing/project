import 'package:flutter/material.dart';
import '../buttons/ds_button.dart';
import '../spacing/ds_spacing.dart';
import '../typography/ds_text_style.dart';

/// Type d'état d'erreur du Design System
enum DSErrorStateType {
  network,
  server,
  unknown,
}

/// État d'erreur du Design System
class DSErrorState extends StatelessWidget {
  final DSErrorStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const DSErrorState({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
  });

  IconData _getIcon() {
    switch (type) {
      case DSErrorStateType.network:
        return Icons.wifi_off;
      case DSErrorStateType.server:
        return Icons.cloud_off;
      case DSErrorStateType.unknown:
        return Icons.error_outline;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case DSErrorStateType.network:
        return 'Erreur de connexion';
      case DSErrorStateType.server:
        return 'Erreur serveur';
      case DSErrorStateType.unknown:
        return 'Une erreur est survenue';
    }
  }

  String _getDefaultMessage() {
    switch (type) {
      case DSErrorStateType.network:
        return 'Vérifiez votre connexion internet et réessayez';
      case DSErrorStateType.server:
        return 'Le serveur ne répond pas. Veuillez réessayer plus tard';
      case DSErrorStateType.unknown:
        return 'Une erreur inattendue s\'est produite';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: DSSpacing.lg),
            Text(
              title ?? _getDefaultTitle(),
              style: DSTextStyle.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              message ?? _getDefaultMessage(),
              style: DSTextStyle.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: DSSpacing.xl),
              DSButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
