import 'package:flutter/material.dart';
import '../buttons/ds_button.dart';
import '../spacing/ds_spacing.dart';
import '../typography/ds_text_style.dart';

/// Type d'état vide du Design System
enum DSEmptyStateType {
  property,
  message,
  favorite,
  notification,
  result,
  generic,
}

/// État vide du Design System
class DSEmptyState extends StatelessWidget {
  final DSEmptyStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const DSEmptyState({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
  });

  IconData _getIcon() {
    switch (type) {
      case DSEmptyStateType.property:
        return Icons.home_outlined;
      case DSEmptyStateType.message:
        return Icons.chat_bubble_outline;
      case DSEmptyStateType.favorite:
        return Icons.favorite_border;
      case DSEmptyStateType.notification:
        return Icons.notifications_none;
      case DSEmptyStateType.result:
        return Icons.search_off;
      case DSEmptyStateType.generic:
        return Icons.inbox_outlined;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case DSEmptyStateType.property:
        return 'Aucun logement';
      case DSEmptyStateType.message:
        return 'Aucun message';
      case DSEmptyStateType.favorite:
        return 'Aucun favori';
      case DSEmptyStateType.notification:
        return 'Aucune notification';
      case DSEmptyStateType.result:
        return 'Aucun résultat';
      case DSEmptyStateType.generic:
        return 'Rien à afficher';
    }
  }

  String _getDefaultMessage() {
    switch (type) {
      case DSEmptyStateType.property:
        return 'Vous n\'avez pas encore de logements enregistrés';
      case DSEmptyStateType.message:
        return 'Vous n\'avez pas encore de messages';
      case DSEmptyStateType.favorite:
        return 'Vous n\'avez pas encore de favoris';
      case DSEmptyStateType.notification:
        return 'Vous n\'avez pas de nouvelles notifications';
      case DSEmptyStateType.result:
        return 'Aucun résultat trouvé pour votre recherche';
      case DSEmptyStateType.generic:
        return 'Il n\'y a rien à afficher pour le moment';
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
