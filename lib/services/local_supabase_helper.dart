import 'local_database.dart';
import 'notification_service.dart';
import 'auto_assignment_service.dart';

class LocalSupabaseHelper {
  final LocalDatabase _db = LocalDatabase.instance;
  final NotificationService _notificationService = NotificationService();
  final TaskNotificationService _taskNotificationService = TaskNotificationService();
  
  LocalSupabaseHelper();

  // Initialize the database
  Future<void> initialize() async {
    await _db.initialize();
  }

  // Reset database for testing (clears all data and recreates defaults)
  Future<void> resetDatabaseForTesting() async {
    await _db.clearAllData();
    await _db.initialize();
    print('✅ Database reset complete');
  }

  // Auth methods
  Future<Map<String, dynamic>?> signIn(String userId, String password) async {
    return await _db.authenticateUser(userId, password);
  }

  Future<Map<String, dynamic>?> signUp({
    required String userId,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    return await _db.insert('users', {
      'userId': userId,
      'password': password,
      'name': name,
      'role': role,
      'email': '$userId@example.com',
    });
  }

  // Database query methods
  Future<List<Map<String, dynamic>>> select(String table, {Map<String, dynamic>? where}) async {
    return await _db.select(table, where: where);
  }

  // Request methods
  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data) async {
    print('Creating request with data: $data'); // Debug
    
    // Create the request first
    final request = await _db.createRequest(data);
    
    print('Created request: $request'); // Debug
    print('Request status: ${request['status']}'); // Debug
    
    // Send notifications to available technicians instead of auto-assigning
    await _taskNotificationService.notifyAvailableTechnicians(request['id']);
    
    // Verify the request was created
    final allRequests = await _db.getAllRequests();
    print('Total requests in database: ${allRequests.length}'); // Debug
    
    return request;
  }

  Future<bool> updateRequest(String id, Map<String, dynamic> data) async {
    return await _db.update('requests', data, where: {'id': id});
  }

  Future<bool> deleteRequest(String id) async {
    return await _db.delete('requests', where: {'id': id});
  }

  // Stream-like methods for compatibility with Supabase
  Stream<List<Map<String, dynamic>>> watchMyRequests() {
    // Since we don't have real-time streams in local storage,
    // we'll return a simple stream that emits once
    return Stream.value(_db.getAllRequests()).asyncMap((future) async => await future);
  }

  Future<List<Map<String, dynamic>>> getRequests({String? userId}) async {
    if (userId != null) {
      return await _db.getUserRequests(userId);
    }
    return await _db.getAllRequests();
  }

  // Task methods
  Future<List<Map<String, dynamic>>> getTasks({String? technicianId}) async {
    if (technicianId != null) {
      return await _db.getTechnicianTasks(technicianId);
    }
    return await _db.select('tasks');
  }

  Future<Map<String, dynamic>> assignTask(String requestId, String technicianId) async {
    // Get the request details first
    final requests = await _db.select('requests', where: {'id': requestId});
    if (requests.isEmpty) {
      throw Exception('Request not found');
    }
    final request = requests.first;
    
    // Get student details
    final studentId = request['userId'];
    final students = await _db.select('users', where: {'userId': studentId});
    final studentName = students.isNotEmpty ? students.first['name'] : 'Unknown';
    
    // Assign the task
    final result = await _db.assignTask(requestId, technicianId);
    
    // Send notification to technician
    _notificationService.addTechnicianTaskNotification(
      taskId: result['id'].toString(),
      requestId: requestId,
      serviceType: request['title'] ?? 'Service',
      location: request['location'] ?? 'Unknown',
      studentName: studentName,
      technicianId: technicianId,
    );
    
    return result;
  }

  // Get technician workload statistics for admin dashboard
  Future<Map<String, dynamic>> getTechnicianWorkloadStats() async {
    return await _taskNotificationService.getTechnicianWorkloadStats();
  }

  // Technician accepts a task notification
  Future<bool> acceptTaskFromNotification(String requestId, String technicianId) async {
    final result = await _taskNotificationService.acceptTask(requestId, technicianId);
    return result != null;
  }

  // Technician rejects a task notification  
  Future<bool> rejectTaskFromNotification(String requestId, String technicianId) async {
    return await _taskNotificationService.rejectTask(requestId, technicianId);
  }

  // Get task notifications for a technician
  List<ServiceNotification> getTaskNotificationsForTechnician(String technicianId) {
    return _notificationService.getTaskNotificationsForTechnician(technicianId);
  }

  // Admin urgent assignment when no technician accepts
  Future<bool> urgentAssignTask(String requestId) async {
    final result = await _taskNotificationService.urgentAssignTask(requestId);
    return result != null;
  }

  // Get escalated tasks for admin dashboard
  Future<List<Map<String, dynamic>>> getEscalatedTasks() async {
    final allRequests = await _db.getAllRequests();
    return allRequests.where((request) => 
      request['status'] == 'escalated'
    ).toList();
  }

  Future<List<Map<String, dynamic>>> getAssignedTasks() async {
    // Get tasks assigned to the current technician
    // For now, return all requests with assigned status
    final allRequests = await _db.getAllRequests();
    return allRequests.where((request) => 
      request['status'] == 'assigned' || request['status'] == 'in_progress'
    ).toList();
  }

  // Get pending requests that need technician action
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final allRequests = await _db.getAllRequests();
    final pendingRequests = allRequests.where((request) => 
      request['status'] == 'pending' || request['status'] == 'escalated'
    ).toList();
    print('getPendingRequests: Found ${pendingRequests.length} pending requests'); // Debug
    for (var request in pendingRequests) {
      print('  - ${request['title']} (${request['status']})'); // Debug
    }
    return pendingRequests;
  }

  // Get tasks for a specific technician
  Future<List<Map<String, dynamic>>> getTasksForTechnician(String technicianId) async {
    final allRequests = await _db.getAllRequests();
    final techTasks = allRequests.where((request) => 
      request['assignedTechnicianId'] == technicianId
    ).toList();
    print('getTasksForTechnician($technicianId): Found ${techTasks.length} assigned tasks'); // Debug
    for (var task in techTasks) {
      print('  - ${task['title']} (${task['status']})'); // Debug
    }
    return techTasks;
  }

  // Technician accepts a task (updated method names for consistency)
  Future<Map<String, dynamic>?> acceptTask(String requestId, String technicianId) async {
    return await _taskNotificationService.acceptTask(requestId, technicianId);
  }

  // Technician rejects a task (updated method names for consistency)
  Future<bool> rejectTask(String requestId, String technicianId) async {
    return await _taskNotificationService.rejectTask(requestId, technicianId);
  }

  // Clear old sample data for testing
  Future<void> clearSampleData() async {
    await _db.clearRequestsAndTasks();
  }

  Future<bool> updateTask(String id, Map<String, dynamic> data) async {
    return await _db.update('tasks', data, where: {'id': id});
  }

  // Notification methods
  Future<List<Map<String, dynamic>>> getNotifications({String? userId}) async {
    if (userId != null) {
      return await _db.select('notifications', where: {'userId': userId});
    }
    return await _db.select('notifications');
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async {
    return await _db.insert('notifications', data);
  }

  Future<bool> markNotificationAsRead(String id) async {
    return await _db.update('notifications', {'read': true}, where: {'id': id});
  }

  // User methods
  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    if (role != null) {
      return await _db.select('users', where: {'role': role});
    }
    return await _db.select('users');
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await _db.getUserById(id);
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    return await _db.update('users', data, where: {'id': id});
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    return await _db.insert('users', data);
  }

  Future<bool> deleteUser(String id) async {
    return await _db.delete('users', where: {'id': id});
  }

  // Generic methods for compatibility
  Future<List<Map<String, dynamic>>> from(String table) async {
    return await _db.select(table);
  }

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    return await _db.insert(table, data);
  }

  Future<bool> update(String table, Map<String, dynamic> data, {required String id}) async {
    return await _db.update(table, data, where: {'id': id});
  }

  Future<bool> delete(String table, {required String id}) async {
    return await _db.delete(table, where: {'id': id});
  }
}
