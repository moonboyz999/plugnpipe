import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<ServiceNotification> _notifications = [];
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final Map<String, Timer> _escalationTimers = {};

  List<ServiceNotification> get notifications =>
      List.unmodifiable(_notifications);

  void addServiceBooking({
    required String serviceType,
    required String location,
    required String date,
    required String time,
    required List<String> issues,
  }) {
    final notification = ServiceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$serviceType Service Booking',
      message:
          'Your $serviceType service has been booked and is pending confirmation.',
      serviceType: serviceType,
      location: location,
      date: date,
      time: time,
      issues: issues,
      timestamp: DateTime.now(),
      isRead: false,
      status: BookingStatus.pending,
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  // Method for when a new task is assigned to technician
  void addTechnicianTaskNotification({
    required String taskId,
    required String requestId,
    required String serviceType,
    required String location,
    required String studentName,
    required String technicianId,
  }) {
    final notification = ServiceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Task Assigned',
      message: 'You have been assigned a $serviceType task at $location for student $studentName.',
      serviceType: serviceType,
      location: location,
      date: '',
      time: '',
      issues: [],
      timestamp: DateTime.now(),
      isRead: false,
      status: BookingStatus.assigned,
      taskId: taskId,
      requestId: requestId,
      technicianId: technicianId,
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
    
    // Start 3-day escalation timer
    _startEscalationTimer(requestId, serviceType, location, studentName);
  }

  // Method for admin escalation after timeout
  void addAdminEscalationNotification(String requestId) {
    final notification = ServiceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🚨 Task Escalation - Action Required',
      message: 'Task request $requestId has not been accepted by any technician. Click to urgently assign or reassign manually.',
      serviceType: 'Service',
      location: '',
      date: '',
      time: '',
      issues: [],
      timestamp: DateTime.now(),
      isRead: false,
      status: BookingStatus.escalated,
      requestId: requestId,
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  // Method for urgent task assignment to technician
  void addUrgentTaskNotification({
    required String taskId,
    required String requestId,
    required String serviceType,
    required String location,
    required String studentName,
    required String technicianId,
  }) {
    final notification = ServiceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🚨 URGENT: Task Assigned',
      message: '⚡ URGENT ASSIGNMENT ⚡\nYou have been assigned an urgent $serviceType task at $location for student $studentName. Please respond immediately.',
      serviceType: serviceType,
      location: location,
      date: '',
      time: '',
      issues: [],
      timestamp: DateTime.now(),
      isRead: false,
      status: BookingStatus.urgent,
      taskId: taskId,
      requestId: requestId,
      technicianId: technicianId,
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  // Enhanced student notification with urgent flag
  void addStudentBookingUpdateNotification({
    required String requestId,
    required String serviceType,
    required String location,
    required String technicianName,
    required bool accepted,
    required String studentId,
    bool isUrgent = false,
  }) {
    final notification = ServiceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: accepted 
        ? (isUrgent ? '🚨 Urgent Service Assigned' : 'Service Accepted') 
        : 'Service Rejected',
      message: accepted 
        ? (isUrgent 
            ? '🚨 Your $serviceType service at $location has been urgently assigned to technician $technicianName due to high priority.'
            : 'Your $serviceType service at $location has been accepted by technician $technicianName.')
        : 'Your $serviceType service at $location has been rejected. We will assign another technician.',
      serviceType: serviceType,
      location: location,
      date: '',
      time: '',
      issues: [],
      timestamp: DateTime.now(),
      isRead: false,
      status: accepted 
        ? (isUrgent ? BookingStatus.urgent : BookingStatus.accepted) 
        : BookingStatus.rejected,
      requestId: requestId,
      studentId: studentId,
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
    
    // Cancel escalation timer if task was accepted
    if (accepted) {
      _cancelEscalationTimer(requestId);
    }
  }

  // Remove task notification for specific technician (when they reject)
  void removeTaskNotificationForTechnician(String requestId, String technicianId) {
    _notifications.removeWhere((notification) => 
      notification.requestId == requestId && 
      notification.technicianId == technicianId &&
      notification.status == BookingStatus.assigned
    );
    _updateUnreadCount();
  }

  // Remove task notifications for all technicians except the one who accepted
  void removeTaskNotificationsExcept(String requestId, String acceptingTechnicianId) {
    _notifications.removeWhere((notification) => 
      notification.requestId == requestId && 
      notification.technicianId != acceptingTechnicianId &&
      notification.status == BookingStatus.assigned
    );
    _updateUnreadCount();
  }

  // Get count of remaining task notifications for a request
  int getTaskNotificationsCount(String requestId) {
    return _notifications.where((notification) => 
      notification.requestId == requestId && 
      notification.status == BookingStatus.assigned
    ).length;
  }

  // Get task notifications for a specific technician
  List<ServiceNotification> getTaskNotificationsForTechnician(String technicianId) {
    return _notifications.where((notification) => 
      notification.technicianId == technicianId && 
      notification.status == BookingStatus.assigned
    ).toList();
  }

  // Start 3-day escalation timer
  void _startEscalationTimer(String requestId, String serviceType, String location, String studentName) {
    // Cancel existing timer if any
    _cancelEscalationTimer(requestId);
    
    // Create timer for 3 days (configurable for production)
    _escalationTimers[requestId] = Timer(
      const Duration(seconds: 10), // Change to Duration(days: 3) for production
      () {
        addAdminEscalationNotification(requestId);
        _escalationTimers.remove(requestId);
      },
    );
  }

  // Cancel escalation timer
  void _cancelEscalationTimer(String requestId) {
    _escalationTimers[requestId]?.cancel();
    _escalationTimers.remove(requestId);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
  }

  void updateBookingStatus(String notificationId, BookingStatus status) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(status: status);
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  void clearAll() {
    _notifications.clear();
    _updateUnreadCount();
  }
}

enum BookingStatus { 
  pending, 
  assigned, 
  accepted, 
  rejected, 
  confirmed, 
  inProgress, 
  completed, 
  cancelled, 
  escalated,
  urgent
}

class ServiceNotification {
  final String id;
  final String title;
  final String message;
  final String serviceType;
  final String location;
  final String date;
  final String time;
  final List<String> issues;
  final DateTime timestamp;
  final bool isRead;
  final BookingStatus status;
  final String? taskId;
  final String? requestId;
  final String? technicianId;
  final String? studentId;

  const ServiceNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.serviceType,
    required this.location,
    required this.date,
    required this.time,
    required this.issues,
    required this.timestamp,
    required this.isRead,
    required this.status,
    this.taskId,
    this.requestId,
    this.technicianId,
    this.studentId,
  });

  ServiceNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? serviceType,
    String? location,
    String? date,
    String? time,
    List<String>? issues,
    DateTime? timestamp,
    bool? isRead,
    BookingStatus? status,
    String? taskId,
    String? requestId,
    String? technicianId,
    String? studentId,
  }) {
    return ServiceNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      serviceType: serviceType ?? this.serviceType,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      issues: issues ?? this.issues,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      requestId: requestId ?? this.requestId,
      technicianId: technicianId ?? this.technicianId,
      studentId: studentId ?? this.studentId,
    );
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.assigned:
        return 'Assigned';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.escalated:
        return 'Escalated';
      case BookingStatus.urgent:
        return '🚨 URGENT';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.assigned:
        return Colors.blue;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.escalated:
        return Colors.deepOrange;
      case BookingStatus.urgent:
        return Colors.red.shade700;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.assigned:
        return Icons.assignment;
      case BookingStatus.accepted:
        return Icons.check_circle;
      case BookingStatus.rejected:
        return Icons.cancel;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.build_circle;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.escalated:
        return Icons.warning;
      case BookingStatus.urgent:
        return Icons.priority_high;
    }
  }
}
