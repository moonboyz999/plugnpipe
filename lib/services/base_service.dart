abstract class BaseService {
  Future<void> ensureAuth();

  Future<Map<String, dynamic>> createRequest({
    required String title,
    required String description,
    required String category,
    String priority = 'medium',
    required String location,
    String? building,
    String? room,
    bool requiresReport = false,
  });

  Future<List<Map<String, dynamic>>> getMyRequests();
  Future<List<Map<String, dynamic>>> getAssignedTasks();
  Future<void> acceptTask(String requestId);
  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
  });
  Future<int> getUnreadNotificationCount();
  Future<List<Map<String, dynamic>>> getAllRequests();
  Future<void> assignTechnician(String requestId, String? technicianId);
}

// Hardcoded base service for local demo
class LocalBaseService {
  static final LocalBaseService _instance = LocalBaseService._internal();
  factory LocalBaseService() => _instance;
  LocalBaseService._internal();

  final List<Map<String, String>> requests = [];

  void createRequest(String title, String details, String user) {
    requests.add({'title': title, 'details': details, 'user': user});
  }

  List<Map<String, String>> getMyRequests(String user) {
    return requests.where((r) => r['user'] == user).toList();
  }
}
