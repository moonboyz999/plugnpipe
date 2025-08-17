import 'local_database.dart';
import 'notification_service.dart';
import 'schedule_service.dart';
import 'task_service.dart';

class TaskNotificationService {
  static final TaskNotificationService _instance = TaskNotificationService._internal();
  factory TaskNotificationService() => _instance;
  TaskNotificationService._internal();

  final LocalDatabase _db = LocalDatabase.instance;
  final NotificationService _notificationService = NotificationService();
  final ScheduleService _scheduleService = ScheduleService();

  // Send task notification to all available technicians
  Future<bool> notifyAvailableTechnicians(String requestId) async {
    try {
      // Get the request details
      final requests = await _db.select('requests', where: {'id': requestId});
      if (requests.isEmpty) {
        throw Exception('Request not found');
      }
      final request = requests.first;

      // Get all available technicians
      final technicians = await _getAvailableTechnicians();
      if (technicians.isEmpty) {
        print('No available technicians found');
        return false;
      }

      // Get student details for notification
      final studentId = request['userId'];
      final students = await _db.select('users', where: {'userId': studentId});
      final studentName = students.isNotEmpty ? students.first['name'] : 'Unknown';

      // Send notification to all available technicians
      for (var technician in technicians) {
        await _sendTaskNotificationToTechnician(
          requestId: requestId,
          request: request,
          technicianId: technician['userId'],
          studentName: studentName,
        );
      }

      print('✅ Task notifications sent to ${technicians.length} technicians for request $requestId');
      return true;
    } catch (e) {
      print('❌ Failed to send task notifications: $e');
      return false;
    }
  }

  // Get available technicians based on workload
  Future<List<Map<String, dynamic>>> _getAvailableTechnicians() async {
    // Get all technicians
    final technicians = await _db.select('users', where: {'role': 'technician'});
    if (technicians.isEmpty) {
      return [];
    }

    // Filter technicians based on current workload
    List<Map<String, dynamic>> availableTechnicians = [];
    for (var tech in technicians) {
      final activeTasks = await _db.select('tasks', where: {
        'technicianId': tech['userId'],
        'status': 'assigned'
      });
      
      // Consider technician available if they have less than 5 active tasks
      if (activeTasks.length < 5) {
        availableTechnicians.add(tech);
      }
    }

    return availableTechnicians;
  }

  // Send task notification to specific technician
  Future<void> _sendTaskNotificationToTechnician({
    required String requestId,
    required Map<String, dynamic> request,
    required String technicianId,
    required String studentName,
  }) async {
    _notificationService.addTechnicianTaskNotification(
      taskId: '', // Will be created when accepted
      requestId: requestId,
      serviceType: request['title'] ?? 'Service',
      location: request['location'] ?? 'Unknown',
      studentName: studentName,
      technicianId: technicianId,
    );
  }

  // Technician accepts a task
  Future<Map<String, dynamic>?> acceptTask(String requestId, String technicianId) async {
    try {
      // Check if request is still available
      final requests = await _db.select('requests', where: {'id': requestId});
      if (requests.isEmpty) {
        throw Exception('Request not found');
      }
      
      final request = requests.first;
      if (request['status'] != 'pending') {
        throw Exception('Request is no longer available');
      }

      // Assign the task to this technician
      final result = await _assignTaskToTechnician(requestId, technicianId, request);
      
      // Remove task notifications for other technicians
      await _removeTaskNotificationsForOtherTechnicians(requestId, technicianId);
      
      // Send confirmation to student
      await _notifyStudentOfAcceptance(requestId, technicianId, request);
      
      print('✅ Task $requestId accepted by technician $technicianId');
      return result;
    } catch (e) {
      print('❌ Failed to accept task: $e');
      return null;
    }
  }

  // Technician rejects a task
  Future<bool> rejectTask(String requestId, String technicianId) async {
    try {
      // Remove notification for this technician
      _notificationService.removeTaskNotificationForTechnician(requestId, technicianId);
      
      // Check if any other technicians are still available
      final remainingNotifications = _notificationService.getTaskNotificationsCount(requestId);
      
      // If no technicians left, escalate to admin
      if (remainingNotifications == 0) {
        await _escalateToAdmin(requestId);
      }
      
      print('✅ Task $requestId rejected by technician $technicianId');
      return true;
    } catch (e) {
      print('❌ Failed to reject task: $e');
      return false;
    }
  }

  // Assign task to specific technician
  Future<Map<String, dynamic>> _assignTaskToTechnician(
    String requestId, 
    String technicianId, 
    Map<String, dynamic> request
  ) async {
    // Update the request with assigned technician
    await _db.update('requests', {
      'assignedTechnicianId': technicianId,
      'status': 'assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    }, where: {'id': requestId});
    
    // Create a task record
    final taskResult = await _db.insert('tasks', {
      'requestId': requestId,
      'technicianId': technicianId,
      'status': 'assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    });

    // Create ServiceTask object and add to schedule
    final serviceTask = ServiceTask(
      id: requestId, // Use requestId as task ID for consistency
      title: request['title'] ?? 'Service Request',
      description: request['description'] ?? 'No description',
      category: _mapCategoryStringToEnum(request['category']),
      priority: _mapPriorityStringToEnum(request['priority']),
      status: TaskStatus.assigned,
      location: request['location'] ?? 'Unknown Location',
      building: request['building'],
      roomNumber: request['room'],
      assignedTechnicianId: technicianId,
      createdAt: DateTime.parse(request['createdAt']),
      requiresReport: request['requiresReport'] ?? true,
    );

    // Add to schedule with default time (can be customized later)
    _scheduleService.addTaskToSchedule(serviceTask, '09:00');
    
    print('✅ Task added to schedule: ${serviceTask.title} for technician $technicianId');
    
    return taskResult;
  }

  // Helper method to map category string to enum
  TaskCategory _mapCategoryStringToEnum(String? category) {
    switch (category?.toLowerCase()) {
      case 'plumbing':
        return TaskCategory.plumbing;
      case 'electrical':
        return TaskCategory.electrical;
      case 'hvac':
        return TaskCategory.hvac;
      case 'appliance':
        return TaskCategory.appliance;
      case 'maintenance':
        return TaskCategory.maintenance;
      default:
        return TaskCategory.maintenance;
    }
  }

  // Helper method to map priority string to enum
  TaskPriority _mapPriorityStringToEnum(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  // Remove task notifications for other technicians
  Future<void> _removeTaskNotificationsForOtherTechnicians(String requestId, String acceptingTechnicianId) async {
    _notificationService.removeTaskNotificationsExcept(requestId, acceptingTechnicianId);
  }

  // Notify student that task has been accepted
  Future<void> _notifyStudentOfAcceptance(String requestId, String technicianId, Map<String, dynamic> request) async {
    // Get technician details
    final technicians = await _db.select('users', where: {'userId': technicianId});
    final technicianName = technicians.isNotEmpty ? technicians.first['name'] : 'Unknown';

    // Get student details
    final studentId = request['userId'];
    
    _notificationService.addStudentBookingUpdateNotification(
      requestId: requestId,
      serviceType: request['title'] ?? 'Service',
      location: request['location'] ?? 'Unknown',
      technicianName: technicianName,
      accepted: true,
      studentId: studentId,
    );
  }

  // Escalate to admin if no technicians accept
  Future<void> _escalateToAdmin(String requestId) async {
    // Update request status to escalated
    await _db.update('requests', {
      'status': 'escalated',
      'escalatedAt': DateTime.now().toIso8601String(),
      'escalationReason': 'No technician accepted within timeframe',
    }, where: {'id': requestId});

    // Send notification to admin with urgent assignment option
    _notificationService.addAdminEscalationNotification(requestId);
  }

  // Admin marks task as urgent and assigns to any available technician
  Future<Map<String, dynamic>?> urgentAssignTask(String requestId) async {
    try {
      // Get the request details
      final requests = await _db.select('requests', where: {'id': requestId});
      if (requests.isEmpty) {
        throw Exception('Request not found');
      }
      final request = requests.first;

      // Find any available technician (even if they have some load)
      final technicians = await _db.select('users', where: {'role': 'technician'});
      if (technicians.isEmpty) {
        throw Exception('No technicians available');
      }

      // Sort by current workload and pick the least busy
      Map<String, int> workloadMap = {};
      for (var tech in technicians) {
        final tasks = await _db.select('tasks', where: {
          'technicianId': tech['userId'],
          'status': 'assigned'
        });
        workloadMap[tech['userId']] = tasks.length;
      }

      technicians.sort((a, b) {
        final workloadA = workloadMap[a['userId']] ?? 0;
        final workloadB = workloadMap[b['userId']] ?? 0;
        return workloadA.compareTo(workloadB);
      });

      final selectedTechnician = technicians.first;

      // Force assign the task with urgent priority
      final result = await _assignUrgentTaskToTechnician(requestId, selectedTechnician['userId'], request);
      
      print('✅ Urgent assignment completed for task $requestId to technician ${selectedTechnician['name']}');
      return result;
    } catch (e) {
      print('❌ Failed to urgent assign task: $e');
      return null;
    }
  }

  // Assign urgent task to specific technician (bypasses normal notification flow)
  Future<Map<String, dynamic>> _assignUrgentTaskToTechnician(
    String requestId, 
    String technicianId, 
    Map<String, dynamic> request
  ) async {
    // Update the request with assigned technician and urgent status
    await _db.update('requests', {
      'assignedTechnicianId': technicianId,
      'status': 'assigned',
      'priority': 'urgent',
      'assignedAt': DateTime.now().toIso8601String(),
      'assignmentType': 'urgent_admin',
    }, where: {'id': requestId});
    
    // Create a task record
    final taskResult = await _db.insert('tasks', {
      'requestId': requestId,
      'technicianId': technicianId,
      'status': 'assigned',
      'priority': 'urgent',
      'assignedAt': DateTime.now().toIso8601String(),
      'assignmentType': 'urgent_admin',
    });

    // Create ServiceTask object and add to schedule
    final serviceTask = ServiceTask(
      id: requestId, // Use requestId as task ID for consistency
      title: request['title'] ?? 'Urgent Service Request',
      description: request['description'] ?? 'No description',
      category: _mapCategoryStringToEnum(request['category']),
      priority: TaskPriority.urgent, // Force urgent priority
      status: TaskStatus.assigned,
      location: request['location'] ?? 'Unknown Location',
      building: request['building'],
      roomNumber: request['room'],
      assignedTechnicianId: technicianId,
      createdAt: DateTime.parse(request['createdAt']),
      requiresReport: request['requiresReport'] ?? true,
      isUrgent: true,
    );

    // Add to schedule with priority time slot
    _scheduleService.addTaskToSchedule(serviceTask, '08:00'); // Earlier slot for urgent tasks
    
    print('✅ Urgent task added to schedule: ${serviceTask.title} for technician $technicianId');

    // Get student and technician details for notifications
    final studentId = request['userId'];
    final students = await _db.select('users', where: {'userId': studentId});
    final studentName = students.isNotEmpty ? students.first['name'] : 'Unknown';

    final technicians = await _db.select('users', where: {'userId': technicianId});
    final technicianName = technicians.isNotEmpty ? technicians.first['name'] : 'Unknown';

    // Send urgent notification to technician
    _notificationService.addUrgentTaskNotification(
      taskId: taskResult['id'].toString(),
      requestId: requestId,
      serviceType: request['title'] ?? 'Service',
      location: request['location'] ?? 'Unknown',
      studentName: studentName,
      technicianId: technicianId,
    );

    // Send notification to student about urgent assignment
    _notificationService.addStudentBookingUpdateNotification(
      requestId: requestId,
      serviceType: request['title'] ?? 'Service',
      location: request['location'] ?? 'Unknown',
      technicianName: technicianName,
      accepted: true,
      studentId: studentId,
      isUrgent: true,
    );

    return taskResult;
  }

  // Get technician workload statistics
  Future<Map<String, dynamic>> getTechnicianWorkloadStats() async {
    final technicians = await _db.select('users', where: {'role': 'technician'});
    Map<String, Map<String, dynamic>> stats = {};

    for (var tech in technicians) {
      final assignedTasks = await _db.select('tasks', where: {
        'technicianId': tech['userId'],
        'status': 'assigned'
      });
      
      final inProgressTasks = await _db.select('tasks', where: {
        'technicianId': tech['userId'],
        'status': 'in_progress'
      });

      final completedTasks = await _db.select('tasks', where: {
        'technicianId': tech['userId'],
        'status': 'completed'
      });

      stats[tech['userId']] = {
        'name': tech['name'],
        'assigned': assignedTasks.length,
        'inProgress': inProgressTasks.length,
        'completed': completedTasks.length,
        'total': assignedTasks.length + inProgressTasks.length,
      };
    }

    return stats;
  }
}

class AutoAssignmentService {
  static final AutoAssignmentService _instance = AutoAssignmentService._internal();
  factory AutoAssignmentService() => _instance;
  AutoAssignmentService._internal();

  final LocalDatabase _db = LocalDatabase.instance;
  final TaskNotificationService _taskNotificationService = TaskNotificationService();

  // Handle urgent request escalation
  Future<bool> handleUrgentRequest(String requestId) async {
    try {
      print('🚨 Handling urgent request: $requestId');
      
      // Update request to urgent priority
      await _db.update('requests', 
        {'priority': 'urgent', 'status': 'pending'}, 
        where: {'id': requestId}
      );

      // Immediately notify all available technicians
      final success = await _taskNotificationService.notifyAvailableTechnicians(requestId);
      
      if (success) {
        print('✅ Urgent request $requestId escalated and notifications sent');
      } else {
        print('❌ Failed to send urgent notifications for request $requestId');
      }
      
      return success;
    } catch (e) {
      print('❌ Error handling urgent request: $e');
      return false;
    }
  }

  // Assign task to available technicians
  Future<bool> assignTask(String requestId) async {
    try {
      print('🔄 Assigning task: $requestId');
      
      // Reset status for reassignment
      await _db.update('requests', 
        {'status': 'pending'}, 
        where: {'id': requestId}
      );

      // Send notifications to available technicians
      final success = await _taskNotificationService.notifyAvailableTechnicians(requestId);
      
      if (success) {
        print('✅ Task $requestId assigned and notifications sent');
      } else {
        print('❌ Failed to assign task $requestId');
      }
      
      return success;
    } catch (e) {
      print('❌ Error assigning task: $e');
      return false;
    }
  }
}
