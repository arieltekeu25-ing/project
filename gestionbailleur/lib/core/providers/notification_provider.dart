import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

/// État du provider de notifications
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isPolling;
  final String? errorMessage;
  final NotificationModel? latestNotification;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isPolling = false,
    this.errorMessage,
    this.latestNotification,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isPolling,
    String? errorMessage,
    NotificationModel? latestNotification,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isPolling: isPolling ?? this.isPolling,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      latestNotification: latestNotification ?? this.latestNotification,
    );
  }
}

/// Provider du repository de notifications
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Provider pour l'état des notifications
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository, ref);
});

/// Notifier pour la gestion des notifications avec polling
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final Ref _ref;
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 30); // Polling toutes les 30 secondes

  NotificationNotifier(this._repository, this._ref) : super(const NotificationState()) {
    // Désactivé temporairement le polling automatique pour éviter les crashes
    // Démarrer le polling automatiquement si l'utilisateur est connecté
    /*
    _ref.listen(authProvider, (previous, next) {
      if (next.estAuthentifie) {
        startPolling();
      } else {
        stopPolling();
      }
    });
    */
  }

  /// Charger les notifications
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie) {
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
        isLoading: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final notifications = await _repository.getNotifications(unreadOnly: unreadOnly);
      final unreadCount = await _repository.getUnreadCount();
      
      // Identifier la notification la plus récente non lue
      NotificationModel? latestUnread;
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      if (unreadNotifications.isNotEmpty) {
        latestUnread = unreadNotifications.reduce(
          (latest, current) => current.createdAt.isAfter(latest.createdAt) ? current : latest,
        );
      }

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        latestNotification: latestUnread,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les notifications',
      );
    }
  }

  /// Démarrer le polling automatique
  void startPolling() {
    final authState = _ref.read(authProvider);
    if (!authState.estAuthentifie || state.isPolling) return;

    state = state.copyWith(isPolling: true);
    
    // Charger immédiatement
    loadNotifications();
    
    // Configurer le polling
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      loadNotifications();
    });
  }

  /// Arrêter le polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      final updatedNotifications = state.notifications.map((n) {
        return n.id == notificationId ? n.copyWith(isRead: true, readAt: DateTime.now()) : n;
      }).toList();
      
      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        latestNotification: state.latestNotification?.id == notificationId 
            ? null 
            : state.latestNotification,
      );
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final success = await _repository.markAllAsRead();
    if (success) {
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
        latestNotification: null,
      );
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    final success = await _repository.deleteNotification(notificationId);
    if (success) {
      final updatedNotifications = state.notifications.where((n) => n.id != notificationId).toList();
      final unreadCount = await _repository.getUnreadCount();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
        latestNotification: state.latestNotification?.id == notificationId 
            ? null 
            : state.latestNotification,
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
