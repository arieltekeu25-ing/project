import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';

/// Page de gestion des notifications réelles de l'utilisateur
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(notificationsProvider.notifier).loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final notifState = ref.watch(notificationsProvider);

    return AppScaffold(
      title: 'Notifications',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      actions: [
        if (authState.estAuthentifie && notifState.unreadCount > 0)
          TextButton.icon(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Tout marquer comme lu'),
          ),
        const SizedBox(width: 8),
      ],
      body: !authState.estAuthentifie
          ? _buildUnauthenticatedState(context, theme)
          : notifState.isLoading && notifState.notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : notifState.errorMessage != null &&
                      notifState.notifications.isEmpty
                  ? _buildErrorState(context, theme, notifState.errorMessage!)
                  : notifState.notifications.isEmpty
                      ? _buildEmptyState(context, theme)
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(notificationsProvider.notifier)
                                .loadNotifications(forceRefresh: true);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(DSSpacing.md),
                            itemCount: notifState.notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifState.notifications[index];
                              return _buildNotificationTile(
                                  context, theme, notif);
                            },
                          ),
                        ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, ThemeData theme, NotificationModel notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      decoration: BoxDecoration(
        color: notif.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead
              ? theme.dividerColor.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: notif.isRead ? 1 : 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notif.isRead
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notif.type == 'MESSAGE'
                ? Icons.chat_bubble_outline
                : notif.type == 'PROPERTY'
                    ? Icons.home_outlined
                    : notif.type == 'VISIT'
                        ? Icons.calendar_today_outlined
                        : Icons.notifications_outlined,
            color: notif.isRead
                ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                : theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 15,
            color: notif.isRead
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: notif.isRead
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(notif.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          if (!notif.isRead) {
            ref.read(notificationsProvider.notifier).markAsRead(notif.id);
          }
          if (notif.type == 'MESSAGE' && notif.relatedId != null) {
            context.push('/chat/${notif.relatedId}');
          } else if (notif.type == 'PROPERTY' && notif.relatedId != null) {
            context.push('/properties/${notif.relatedId}');
          }
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            if (!notif.isRead)
              IconButton(
                icon: const Icon(Icons.mark_email_read, size: 20),
                color: theme.colorScheme.primary,
                onPressed: () {
                  ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                },
                tooltip: 'Marquer comme lu',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              onPressed: () {
                _showDeleteNotificationDialog(context, notif);
              },
              tooltip: 'Supprimer',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteNotificationDialog(BuildContext context, NotificationModel notif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la notification'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette notification ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationsProvider.notifier).deleteNotification(notif.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous pour voir vos notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeLogin),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Vous n'avez aucune notification.",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Les alertes de nouveaux messages et d'activités apparaîtront ici.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(error, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(notificationsProvider.notifier)
                  .loadNotifications(forceRefresh: true);
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} à $hour:$minute';
  }
}
