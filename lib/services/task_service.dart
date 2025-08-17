// Enums for task management
enum TaskStatus { pending, assigned, inProgress, completed, cancelled }

enum TaskPriority { low, medium, high, urgent }

enum TaskCategory { plumbing, electrical, hvac, general, appliance, maintenance }

enum TaskNotificationType { newTask, taskUpdate, reminder }

// Task notification model
class TaskNotification {
  final String id;
  final String title;
  final String message;
  final TaskNotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? taskId;

  TaskNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.taskId,
  });

  // Alias for createdAt to match expected property name
  DateTime get timestamp => createdAt;
}

// Task model
class ServiceTask {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final TaskStatus status;
  final String location;
  final String? building;
  final String? roomNumber;
  final String? assignedTechnicianId;
  final DateTime createdAt;
  final DateTime? estimatedCompletion;
  final DateTime? actualCompletion;
  final bool requiresReport; // whether a technician report is required
  final bool isUrgent; // convenience flag for urgent display
  final bool sentForAdminReview; // after technician submits report

  ServiceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.location,
    this.building,
    this.roomNumber,
    this.assignedTechnicianId,
    required this.createdAt,
    this.estimatedCompletion,
    this.actualCompletion,
    this.requiresReport = true,
    this.isUrgent = false,
    this.sentForAdminReview = false,
  });
}

// Status report model
class StatusReport {
  final String id;
  final String taskId;
  final String workCompleted;
  final String materialsUsed;
  final String issuesEncountered;
  final String recommendations;
  final DateTime createdAt;
  final bool isSubmitted;
  final bool sentToAdmin; // mark when forwarded to admin
  final bool approvedByAdmin; // admin approval status

  StatusReport({
    required this.id,
    required this.taskId,
    required this.workCompleted,
    required this.materialsUsed,
    required this.issuesEncountered,
    required this.recommendations,
    required this.createdAt,
    required this.isSubmitted,
    this.sentToAdmin = false,
    this.approvedByAdmin = false,
  });
}

// Task service for managing tasks and notifications
class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  
  bool _isInitialized = false;
  
  TaskService._internal() {
    // Service initialized without sample data
    _isInitialized = true;
  }

  // Application data
  final List<ServiceTask> _tasks = [];
  final List<TaskNotification> _notifications = [];
  final Map<String, StatusReport> _reports = {}; // taskId -> latest report
  final List<String> _technicianIds = ['tech_001', 'tech_002', 'tech_003']; // available technicians
  int _techRoundRobinIndex = 0;

  // Get all tasks
  List<ServiceTask> get tasks => _tasks;

  // Get completed tasks
  List<ServiceTask> getCompletedTasks() {
    return _tasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  // Get completed tasks with submitted reports (for work history)
  List<ServiceTask> getCompletedTasksWithSubmittedReports() {
    return _tasks.where((task) {
      final report = _reports[task.id];
      return task.status == TaskStatus.completed && 
             report != null && 
             report.isSubmitted;
    }).toList();
  }

  // Get notifications
  List<TaskNotification> get notifications => _notifications;

  // Auto-assign next technician (round-robin)
  String _autoAssignTechnician() {
    if (_technicianIds.isEmpty) return 'tech_001';
    final techId = _technicianIds[_techRoundRobinIndex % _technicianIds.length];
    _techRoundRobinIndex++;
    return techId;
  }

  // Create a new task (service booked) auto-assign technician & set urgency
  ServiceTask createTask({
    required String title,
    required String description,
    required TaskCategory category,
    TaskPriority priority = TaskPriority.low,
    String location = 'N/A',
    bool markUrgent = false,
  }) {
    final task = ServiceTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      priority: markUrgent ? TaskPriority.urgent : priority,
      status: TaskStatus.pending,
      location: location,
      createdAt: DateTime.now(),
      assignedTechnicianId: _autoAssignTechnician(),
      isUrgent: markUrgent || priority == TaskPriority.urgent,
    );
    _tasks.add(task);
    _notifications.add(
      TaskNotification(
        id: 'ntf_${task.id}',
        title: 'New Task Assigned',
        message: 'Task "${task.title}" assigned to technician',
        type: TaskNotificationType.newTask,
        createdAt: DateTime.now(),
        taskId: task.id,
      ),
    );
    return task;
  }

  // Simulate new task notification
  void simulateNewTask() {
    _notifications.add(
      TaskNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Task Assigned',
        message: 'You have been assigned a new maintenance task',
        type: TaskNotificationType.newTask,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Get tasks by status
  List<ServiceTask> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Get tasks by priority
  List<ServiceTask> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Callback for when tasks are completed (to notify schedule service)
  static Function(String taskId)? _onTaskCompleted;
  
  static void setTaskCompletedCallback(Function(String taskId) callback) {
    _onTaskCompleted = callback;
  }

  // Update task status
  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final oldTask = _tasks[taskIndex];
      
      // Create updated task with new status
      final updatedTask = ServiceTask(
        id: oldTask.id,
        title: oldTask.title,
        description: oldTask.description,
        category: oldTask.category,
        priority: oldTask.priority,
        status: newStatus,
        location: oldTask.location,
        building: oldTask.building,
        roomNumber: oldTask.roomNumber,
        assignedTechnicianId: oldTask.assignedTechnicianId,
        createdAt: oldTask.createdAt,
        estimatedCompletion: oldTask.estimatedCompletion,
        actualCompletion: newStatus == TaskStatus.completed ? DateTime.now() : oldTask.actualCompletion,
        requiresReport: oldTask.requiresReport,
      );
      
      // Update the task in the list
      _tasks[taskIndex] = updatedTask;
      
      // If task is completed, notify schedule service
      if (newStatus == TaskStatus.completed && _onTaskCompleted != null) {
        _onTaskCompleted!(taskId);
      }
      
      // Add notification
      _notifications.add(
        TaskNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Task Updated',
          message: 'Task status changed to ${newStatus.name}',
          type: TaskNotificationType.taskUpdate,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // Mark notification as read
  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // In a real app, you would update this in the database
    }
  }

  // Get unread notifications count
  int get unreadNotificationsCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Additional getters and methods needed by the screens
  int get unreadNotificationCount => unreadNotificationsCount;
  List<TaskNotification> get taskNotifications => _notifications;

  // Get tasks with draft reports
  List<ServiceTask> getTasksWithDraftReports() {
    return _tasks.where((task) {
      final report = _reports[task.id];
      return report != null && !report.isSubmitted;
    }).toList();
  }

  // Get completed tasks needing reports (no report or only draft reports)
  List<ServiceTask> getCompletedTasksNeedingReports() {
    return _tasks.where((task) {
      final report = _reports[task.id];
      return task.status == TaskStatus.completed && 
             (report == null || !report.isSubmitted);
    }).toList();
  }

  // Save draft report
  void saveDraftReport(String taskId, StatusReport report) {
    // In a real app, this would save to database
    _reports[taskId] = report;
    _notifications.add(
      TaskNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Draft Saved',
        message: 'Report draft saved successfully',
        type: TaskNotificationType.taskUpdate,
        createdAt: DateTime.now(),
        taskId: taskId,
      ),
    );
  }

  // Submit report
  void submitReport(String taskId, StatusReport report) {
    // Store report & mark as submitted, send to admin review queue
    final submitted = StatusReport(
      id: report.id,
      taskId: report.taskId,
      workCompleted: report.workCompleted,
      materialsUsed: report.materialsUsed,
      issuesEncountered: report.issuesEncountered,
      recommendations: report.recommendations,
      createdAt: report.createdAt,
      isSubmitted: true,
      sentToAdmin: true,
      approvedByAdmin: false,
    );
    _reports[taskId] = submitted;
    updateTaskStatus(taskId, TaskStatus.completed);
    _notifications.add(
      TaskNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Report Submitted',
        message: 'Report sent for admin review',
        type: TaskNotificationType.taskUpdate,
        createdAt: DateTime.now(),
        taskId: taskId,
      ),
    );
  }

  // Get report for a task
  StatusReport? getReport(String taskId) => _reports[taskId];

  // Tasks whose reports are awaiting admin review
  List<ServiceTask> get tasksAwaitingAdminReview => _tasks.where((t) {
    final r = _reports[t.id];
    return r?.sentToAdmin == true && r?.approvedByAdmin == false;
  }).toList();

  // Admin approves a report
  void adminApproveReport(String taskId) {
    final report = _reports[taskId];
    if (report != null) {
      _reports[taskId] = StatusReport(
        id: report.id,
        taskId: report.taskId,
        workCompleted: report.workCompleted,
        materialsUsed: report.materialsUsed,
        issuesEncountered: report.issuesEncountered,
        recommendations: report.recommendations,
        createdAt: report.createdAt,
        isSubmitted: report.isSubmitted,
        sentToAdmin: true,
        approvedByAdmin: true,
      );
      _notifications.add(
        TaskNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Report Approved',
          message: 'Admin approved report for task',
          type: TaskNotificationType.taskUpdate,
          createdAt: DateTime.now(),
          taskId: taskId,
        ),
      );
    }
  }

  // Admin rejects a report (send back to technician)
  void adminRejectReport(String taskId, {String reason = 'Needs revision'}) {
    final report = _reports[taskId];
    if (report != null) {
      _reports[taskId] = StatusReport(
        id: report.id,
        taskId: report.taskId,
        workCompleted: report.workCompleted,
        materialsUsed: report.materialsUsed,
        issuesEncountered: report.issuesEncountered,
        recommendations: '${report.recommendations}\n[Admin Note] $reason',
        createdAt: report.createdAt,
        isSubmitted: false, // back to draft state
        sentToAdmin: false,
        approvedByAdmin: false,
      );
      _notifications.add(
        TaskNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Report Rejected',
          message: 'Admin requested changes: $reason',
          type: TaskNotificationType.taskUpdate,
          createdAt: DateTime.now(),
          taskId: taskId,
        ),
      );
    }
  }

  // Mark task as accepted
  void markTaskAsAccepted(String taskId) {
    updateTaskStatus(taskId, TaskStatus.inProgress);
  }

  // Mark all notifications as read
  void markAllNotificationsAsRead() {
    // In a real app, update database to mark all as read
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
  }
}
