import 'dart:developer';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService(this.apiClient);

  // Get notifications with pagination
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // User requested to fetch all notifications even if limit is passed as 20
      const int effectiveLimit = 1000;
      final offset = (page - 1) * effectiveLimit;
      final queryParameters = {
        'limit': effectiveLimit.toString(),
        'offset': offset.toString(),
      };
      log("NotificationService queryParameters: $queryParameters");

      final response = await apiClient.get(
        ApiEndpoints.getNotifications,
        queryParameters: queryParameters,
        authenticated: true,
      );
      log("NotificationService response: $response");

      if (response['status'] == 'success') {
        final notifications = (response['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        if (notifications.isNotEmpty) {
          log("NotificationService Notifications: ${notifications[0]}");
        } else {
          log("NotificationService Notifications: []");
        }
        return notifications;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      log('Error fetching notifications: $e');
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUnreadCount,
        authenticated: true,
      );
      log("NotificationService response: $response");
      if (response['status'] == 'success') {
        return int.tryParse(response['count'].toString()) ??
            int.tryParse(response['unread_count'].toString()) ??
            0;
      } else {
        return 0;
      }
    } catch (e) {
      log('Error fetching unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(int? notificationId) async {
    try {
      final body = notificationId != null ? {'id': notificationId} : {};

      final response = await apiClient.post(
        ApiEndpoints.markNotificationRead,
        body,
        authenticated: true,
      );

      return response['status'] == 'success';
    } catch (e) {
      log('Error marking notification as read: $e');
      return false;
    }
  }
}
