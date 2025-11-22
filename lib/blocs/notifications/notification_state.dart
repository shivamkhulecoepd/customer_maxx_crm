import 'package:equatable/equatable.dart';
import 'package:customer_maxx_crm/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationModel? latestNotification;
  final bool hasNewNotification; // Trigger for UI pop-up

  const NotificationLoaded({
    this.notifications = const [],
    this.unreadCount = 0,
    this.latestNotification,
    this.hasNewNotification = false,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    NotificationModel? latestNotification,
    bool? hasNewNotification,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      latestNotification: latestNotification ?? this.latestNotification,
      hasNewNotification: hasNewNotification ?? this.hasNewNotification,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    latestNotification,
    hasNewNotification,
  ];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
