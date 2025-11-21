import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

import '../../utils/api_service_locator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _notificationService = ServiceLocator.notificationService;
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (_isLoading && _page > 1)
      return; // Prevent multiple loads unless it's the first page

    setState(() {
      _isLoading = true;
      if (_page == 1) _error = null;
    });

    try {
      final notifications = await _notificationService.getNotifications(
        page: _page,
      );
      setState(() {
        if (_page == 1) {
          _notifications = notifications;
        } else {
          _notifications.addAll(notifications);
        }
        _hasMore = notifications.length >= 1000; // Limit increased to 1000
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final success = await _notificationService.markAsRead(notification.id);
      if (success) {
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            // Create a new object with isRead = true
            // Since fields are final, we can't just modify it.
            // In a real app, we might want copyWith method on model.
            // For now, we'll just reload or ignore visual update if model is immutable without copyWith
            _notifications[index] = NotificationModel(
              id: notification.id,
              userId: notification.userId,
              message: notification.message,
              type: notification.type,
              relatedId: notification.relatedId,
              isRead: true,
              createdAt: notification.createdAt,
              timeAgo: notification.timeAgo,
              leadName: notification.leadName,
              leadPhone: notification.leadPhone,
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to mark as read: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await _notificationService.markAsRead(null); // null means all
              _page = 1;
              _loadNotifications();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: () {
                _page = 1;
                _loadNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _loadNotifications();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Implement delete if API supports it, otherwise just hide
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification.isRead
                    ? Colors.grey[300]
                    : Colors.blue,
                child: Icon(
                  _getIconForType(notification.type),
                  color: notification.isRead ? Colors.grey : Colors.white,
                ),
              ),
              title: Text(
                notification.message,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.leadName != null)
                    Text('Lead: ${notification.leadName}'),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              onTap: () {
                _markAsRead(notification);
                // Navigate to lead details if relatedId exists
                // if (notification.relatedId != null) {
                //   Navigator.pushNamed(context, '/lead-details', arguments: notification.relatedId);
                // }
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'lead_assigned':
        return Icons.person_add;
      case 'lead_status_update':
        return Icons.update;
      case 'stale_lead':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }
}
