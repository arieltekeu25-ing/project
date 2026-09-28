import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;
  final bool hasAttemptedFetch;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
    this.hasAttemptedFetch = false,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
    bool? hasAttemptedFetch,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unreadCount: unreadCount ?? this.unreadCount,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsNotifier(repository, ref);
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;
  final Ref _ref;

  NotificationsNotifier(this._repository, this._ref)
      : super(const NotificationsState());

  /// Charger la liste des notifications réelles
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) {
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
      return;
    }

    if (!forceRefresh && state.hasAttemptedFetch && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final notifications = await _repository.getNotifications();
      final unread = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        isLoading: false,
        hasAttemptedFetch: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasAttemptedFetch: true,
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  /// Charger le nombre de notifications non lues
  Future<void> refreshUnreadCount() async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return;

    final unread = await _repository.getUnreadCount();
    state = state.copyWith(unreadCount: unread);
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return;

    final success = await _repository.markAllAsRead();
    if (success) {
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    }
  }

  /// Marquer une notification individuelle comme lue
  Future<void> markAsRead(String notificationId) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return;

    try {
      final success = await _repository.markAsRead(notificationId);
      if (success) {
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        final unread = updated.where((n) => !n.isRead).length;
        state = state.copyWith(notifications: updated, unreadCount: unread);
      }
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) return;

    try {
      final success = await _repository.deleteNotification(notificationId);
      if (success) {
        final updated = state.notifications.where((n) => n.id != notificationId).toList();
        final unread = updated.where((n) => !n.isRead).length;
        state = state.copyWith(notifications: updated, unreadCount: unread);
      } else {
        // Si toutes les méthodes ont échoué, supprimer quand même localement pour l'UX
        final updated = state.notifications.where((n) => n.id != notificationId).toList();
        final unread = updated.where((n) => !n.isRead).length;
        state = state.copyWith(notifications: updated, unreadCount: unread);
      }
    } catch (e) {
      // En cas d'erreur grave, supprimer quand même localement pour l'UX
      final updated = state.notifications.where((n) => n.id != notificationId).toList();
      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unread);
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('SocketException') || str.contains('NetworkException')) {
      return 'Impossible de contacter le serveur.';
    }
    return 'Erreur lors du chargement de vos notifications.';
  }
}
