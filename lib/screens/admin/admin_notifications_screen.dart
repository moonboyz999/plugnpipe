import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final LocalSupabaseHelper _dbHelper = LocalSupabaseHelper();
  List<Map<String, dynamic>> _systemNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);
      
      // Get system-wide notifications for admin
      final requests = await _dbHelper.getRequests();
      final tasks = await _dbHelper.getTasks();
      
      // Generate admin-relevant notifications
      List<Map<String, dynamic>> notifications = [];
      
      // Urgent requests notification
      final urgentRequests = requests.where((r) => r['priority'] == 'urgent').length;
      if (urgentRequests > 0) {
        notifications.add({
          'id': 'urgent_requests',
          'title': 'Urgent Requests',
          'message': '$urgentRequests urgent maintenance request${urgentRequests > 1 ? 's' : ''} requiring immediate attention',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'urgent',
          'icon': Icons.emergency,
          'color': Colors.red,
        });
      }
      
      // Rejected tasks notification
      final rejectedTasks = requests.where((r) => r['status'] == 'rejected').length;
      if (rejectedTasks > 0) {
        notifications.add({
          'id': 'rejected_tasks',
          'title': 'Rejected Tasks',
          'message': '$rejectedTasks task${rejectedTasks > 1 ? 's' : ''} rejected and may need escalation',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'type': 'warning',
          'icon': Icons.cancel,
          'color': Colors.orange,
        });
      }
      
      // Pending assignments notification
      final pendingRequests = requests.where((r) => r['status'] == 'pending').length;
      if (pendingRequests > 5) {
        notifications.add({
          'id': 'pending_assignments',
          'title': 'High Volume of Pending Requests',
          'message': '$pendingRequests requests awaiting assignment',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'type': 'info',
          'icon': Icons.assignment_late,
          'color': Colors.blue,
        });
      }
      
      // System performance notification
      notifications.add({
        'id': 'system_status',
        'title': 'System Status',
        'message': 'All systems operational. ${tasks.length} total tasks managed today.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'type': 'success',
        'icon': Icons.check_circle,
        'color': Colors.green,
      });
      
      if (mounted) {
        setState(() {
          _systemNotifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading admin notifications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Admin Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _systemNotifications.isEmpty
                      ? const Center(
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
                                'No notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _systemNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = _systemNotifications[index];
                              return _buildNotificationCard(notification);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final color = notification['color'] as Color;
    final icon = notification['icon'] as IconData;
    final timestamp = DateTime.parse(notification['timestamp']);
    final timeAgo = _getTimeAgo(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (notification['type'] == 'urgent' || notification['type'] == 'warning')
                IconButton(
                  onPressed: () => _handleNotificationAction(notification),
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    // Handle notification-specific actions
    switch (notification['id']) {
      case 'urgent_requests':
        // Navigate to urgent requests (could switch to Emergency tab)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigate to urgent requests management'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case 'rejected_tasks':
        // Navigate to rejected tasks (could switch to Rejected tab)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigate to rejected tasks management'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      default:
        break;
    }
  }
}
