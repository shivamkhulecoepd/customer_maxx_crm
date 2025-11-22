import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/services/notification_service.dart';
import 'package:customer_maxx_crm/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;
  Timer? _pollingTimer;

  NotificationBloc(this._notificationService) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<StartNotificationPolling>(_onStartPolling);
    on<StopNotificationPolling>(_onStopPolling);
    on<CheckUnreadCount>(_onCheckUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Only show loading indicator if it's not a refresh (background update)
    if (!event.refresh && state is! NotificationLoaded) {
      emit(NotificationLoading());
    }

    try {
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();

      NotificationModel? latest;
      if (notifications.isNotEmpty) {
        latest = notifications.first;
      }

      bool hasNew = false;
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        // Check if we have a new notification by comparing IDs
        if (latest != null && currentState.latestNotification != null) {
          if (latest.id != currentState.latestNotification!.id) {
            hasNew = true;
            log('New notification detected: ${latest.message}');
          }
        } else if (latest != null && currentState.latestNotification == null) {
          // First time loading or previously empty, don't trigger popup unless it's a refresh
          if (event.refresh) hasNew = true;
        }
      }

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          latestNotification: latest,
          hasNewNotification: hasNew,
        ),
      );

      // Reset the "hasNewNotification" flag after a short delay so it doesn't keep triggering
      if (hasNew) {
        // We can't easily "wait" here without blocking, but the UI should consume this flag
        // and then we can emit a state with it set to false if needed,
        // or the UI handles it as a one-shot event.
        // For now, let's leave it. The UI listener should handle the "one-time" nature.
      }
    } catch (e) {
      if (!event.refresh) {
        emit(NotificationError(e.toString()));
      } else {
        log('Error refreshing notifications: $e');
      }
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationService.markAsRead(event.notificationId);
      // Refresh list and count
      add(const LoadNotifications(refresh: true));
    } catch (e) {
      log('Error marking as read: $e');
    }
  }

  void _onStartPolling(
    StartNotificationPolling event,
    Emitter<NotificationState> emit,
  ) {
    _pollingTimer?.cancel();
    log('Starting notification polling (every 15s)');
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      add(const LoadNotifications(refresh: true));
    });
  }

  void _onStopPolling(
    StopNotificationPolling event,
    Emitter<NotificationState> emit,
  ) {
    log('Stopping notification polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _onCheckUnreadCount(
    CheckUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    // Lightweight check, maybe just count
    // For now, reusing LoadNotifications is safer to keep sync
    add(const LoadNotifications(refresh: true));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
