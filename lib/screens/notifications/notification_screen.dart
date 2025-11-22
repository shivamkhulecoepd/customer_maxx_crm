import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/widgets/notification_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

import '../../utils/api_service_locator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final bool showDrawer = true;
  late NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final List<Widget>? actions = [];

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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _buildCustomAppBar(context, isDarkMode),
            centerTitle: true,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
          body: _buildBody(isDarkMode),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          // Menu/Back Button
          if (showDrawer)
            Builder(
              builder: (BuildContext context) {
                return _buildIconButton(
                  context,
                  Icons.arrow_back_ios,
                  () => Navigator.pop(context),
                  isDarkMode,
                );
              },
            ),
          SizedBox(width: width < 360 ? 8 : 12),

          // Title
          Expanded(
            child: Text(
              "Notifications",
              style: TextStyle(
                fontSize: width < 360 ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Actions
          if (actions != null) ...actions!,
          SizedBox(width: width < 360 ? 6 : 8),

          // Theme Toggle
          _buildIconButton(context, Icons.done_all, () async {
            await _notificationService.markAsRead(null); // null means all
            _page = 1;
            _loadNotifications();
          }, isDarkMode),

          SizedBox(width: width < 360 ? 6 : 8),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    final width = MediaQuery.of(context).size.width;
    final buttonSize = width < 360 ? 36.0 : 44.0;
    final iconSize = width < 360 ? 18.0 : 20.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          size: iconSize,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading && _notifications.isEmpty) {
      return _buildShimmerLoading(isDarkMode);
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
        padding: const EdgeInsets.all(8),
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = _notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? (notification.isRead ? Colors.grey[850] : Colors.grey[900])
                  : (notification.isRead ? Colors.grey[50] : Colors.white),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header shimmer
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Notification items shimmer
            for (int i = 0; i < 10; i++)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
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
