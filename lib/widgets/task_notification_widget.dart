import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/local_supabase_helper.dart';

class TaskNotificationWidget extends StatefulWidget {
  final String technicianId;

  const TaskNotificationWidget({
    super.key,
    required this.technicianId,
  });

  @override
  State<TaskNotificationWidget> createState() => _TaskNotificationWidgetState();
}

class _TaskNotificationWidgetState extends State<TaskNotificationWidget> {
  final LocalSupabaseHelper _helper = LocalSupabaseHelper();
  List<ServiceNotification> _taskNotifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTaskNotifications();
  }

  void _loadTaskNotifications() {
    setState(() {
      _taskNotifications = _helper.getTaskNotificationsForTechnician(widget.technicianId);
    });
  }

  Future<void> _acceptTask(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _helper.acceptTaskFromNotification(requestId, widget.technicianId);
      
      if (success) {
        _showMessage('Task accepted successfully!', isSuccess: true);
        _loadTaskNotifications(); // Refresh notifications
      } else {
        _showMessage('Failed to accept task. It may have been taken by another technician.', isSuccess: false);
      }
    } catch (e) {
      _showMessage('Error accepting task: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectTask(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _helper.rejectTaskFromNotification(requestId, widget.technicianId);
      
      if (success) {
        _showMessage('Task rejected. Other technicians will be notified.', isSuccess: true);
        _loadTaskNotifications(); // Refresh notifications
      } else {
        _showMessage('Failed to reject task.', isSuccess: false);
      }
    } catch (e) {
      _showMessage('Error rejecting task: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildTaskNotificationCard(ServiceNotification notification) {
    final isUrgent = notification.status == BookingStatus.urgent;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isUrgent ? 6 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUrgent ? Border.all(color: Colors.red.shade700, width: 2) : null,
          gradient: isUrgent ? LinearGradient(
            colors: [Colors.red.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with service type and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isUrgent) ...[
                          Icon(Icons.priority_high, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            notification.serviceType,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isUrgent ? Colors.red.shade700 : const Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Urgent banner
              if (isUrgent) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🚨 URGENT ASSIGNMENT - IMMEDIATE RESPONSE REQUIRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Location and message
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    notification.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              if (notification.status == BookingStatus.assigned || notification.status == BookingStatus.urgent)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _acceptTask(notification.requestId!),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          isUrgent ? 'Accept Urgent' : 'Accept',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUrgent ? Colors.red.shade700 : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (!isUrgent) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _rejectTask(notification.requestId!),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('Reject', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              const Text(
                'New Task Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_taskNotifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_taskNotifications.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Loading indicator
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        
        // Task notifications list
        if (_taskNotifications.isEmpty && !_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No new task notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll receive notifications when new tasks are available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (!_isLoading)
          Expanded(
            child: ListView.builder(
              itemCount: _taskNotifications.length,
              itemBuilder: (context, index) {
                return _buildTaskNotificationCard(_taskNotifications[index]);
              },
            ),
          ),
      ],
    );
  }
}
