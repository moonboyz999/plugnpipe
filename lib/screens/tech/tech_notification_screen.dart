import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/local_auth_service_demo.dart';

class TechNotificationScreen extends StatefulWidget {
  const TechNotificationScreen({super.key});

  @override
  State<TechNotificationScreen> createState() => _TechNotificationScreenState();
}

class _TechNotificationScreenState extends State<TechNotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final LocalAuthService _authService = LocalAuthService();

  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header with gradient
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          Text(
                            'Task updates and notifications',
                            style: TextStyle(fontSize: 14, color: Colors.brown),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showClearAllDialog();
                      },
                      icon: const Icon(Icons.clear_all, color: Colors.brown),
                      tooltip: 'Clear All',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _notificationService.unreadCount,
              builder: (context, unreadCount, child) {
                final currentUser = _authService.currentUser;
                if (currentUser == null) {
                  return const Center(
                    child: Text(
                      'Please log in to view notifications',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Get notifications for current technician
                final techNotifications = _notificationService
                    .getTaskNotificationsForTechnician(currentUser['userId']);

                if (techNotifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No task notifications',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'New task assignments will appear here',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: techNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = techNotifications[index];
                    return _buildTaskNotificationCard(notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskNotificationCard(ServiceNotification notification) {
    final isUrgent = notification.status == BookingStatus.urgent;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _notificationService.markAsRead(notification.id);
            setState(() {});
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isUrgent 
                ? Colors.red.withOpacity(0.05)
                : (notification.isRead
                    ? Colors.white
                    : Colors.blue.withOpacity(0.05)),
            border: Border.all(
              color: isUrgent
                  ? Colors.red.withOpacity(0.3)
                  : (notification.isRead
                      ? Colors.grey[200]!
                      : Colors.blue.withOpacity(0.2)),
              width: notification.isRead ? 1 : 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    notification.statusIcon,
                    color: notification.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
