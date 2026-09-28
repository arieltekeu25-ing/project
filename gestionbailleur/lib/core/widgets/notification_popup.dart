import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

/// Widget de pop-up de notification qui s'affiche automatiquement
class NotificationPopup extends ConsumerStatefulWidget {
  const NotificationPopup({super.key});

  @override
  ConsumerState<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends ConsumerState<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = false;
  NotificationModel? _currentNotification;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Écouter les nouvelles notifications
    ref.listen<NotificationState>(notificationProvider, (previous, next) {
      if (next.latestNotification != null && 
          (previous?.latestNotification?.id != next.latestNotification?.id)) {
        _showNotification(next.latestNotification!);
      }
    });
  }

  void _showNotification(NotificationModel notification) {
    if (!mounted) return;
    
    setState(() {
      _currentNotification = notification;
      _isVisible = true;
    });
    
    _controller.forward();

    // Masquer automatiquement après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isVisible) {
        _hideNotification();
      }
    });
  }

  void _hideNotification() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _currentNotification = null;
        });
      }
    });
  }

  void _handleTap() {
    // Marquer comme lue et naviguer vers la page de notifications
    ref.read(notificationProvider.notifier).markAsRead(_currentNotification!.id);
    _hideNotification();
    
    // TODO: Naviguer vers la page de notifications quand elle sera créée
    // context.go('/notifications');
  }

  void _handleDismiss() {
    _hideNotification();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _currentNotification == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final notification = _currentNotification!;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header avec bouton dismiss
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getNotificationIcon(notification.type),
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: _handleDismiss,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        notification.body,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Footer avec temps
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                          ),
                          TextButton(
                            onPressed: _handleTap,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Voir', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'visit':
        return Icons.calendar_today;
      case 'property':
        return Icons.home;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
