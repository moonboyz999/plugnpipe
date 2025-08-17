import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static LocalDatabase? _instance;
  static LocalDatabase get instance => _instance ??= LocalDatabase._();
  LocalDatabase._();

  // In-memory storage for current session
  final Map<String, List<Map<String, dynamic>>> _memoryData = {
    'users': [],
    'requests': [],
    'tasks': [],
    'notifications': [],
  };

  // Initialize with some default data
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load data from persistent storage
    for (String table in _memoryData.keys) {
      final jsonString = prefs.getString(table);
      if (jsonString != null) {
        _memoryData[table] = List<Map<String, dynamic>>.from(
          json.decode(jsonString).map((item) => Map<String, dynamic>.from(item))
        );
      }
    }

    // Add default users if none exist
    if (_memoryData['users']!.isEmpty) {
      await _addDefaultUsers();
    }

    // Add sample data if none exist
    if (_memoryData['requests']!.isEmpty) {
      await _addSampleData();
    }
  }

  // Save data to persistent storage
  Future<void> _saveToStorage(String table) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(table, json.encode(_memoryData[table]));
  }

  // Add default users
  Future<void> _addDefaultUsers() async {
    final defaultUsers = [
      {
        'id': '1',
        'userId': 'student_001',
        'password': 'student123',
        'name': 'Test Student',
        'role': 'student',
        'email': 'student@test.com',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'userId': 'tech_001',
        'password': 'tech123',
        'name': 'Test Technician',
        'role': 'technician',
        'email': 'tech@test.com',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'userId': 'admin_001',
        'password': 'admin123',
        'name': 'Test Admin',
        'role': 'admin',
        'email': 'admin@test.com',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    _memoryData['users']!.addAll(defaultUsers);
    await _saveToStorage('users');
  }

  // Add sample requests and tasks
  Future<void> _addSampleData() async {
    // Only add sample data if no requests exist yet
    final existingRequests = _memoryData['requests']!;
    if (existingRequests.isNotEmpty) {
      print('Requests already exist, skipping sample data');
      return;
    }

    final List<Map<String, dynamic>> sampleRequests = [
      // Removed old sample data to avoid confusion with real requests
      // Real requests will be created through the app flow
    ];

    final List<Map<String, dynamic>> sampleTasks = [
      // Removed old sample tasks
    ];

    _memoryData['requests']!.addAll(sampleRequests);
    _memoryData['tasks']!.addAll(sampleTasks);
    
    await _saveToStorage('requests');
    await _saveToStorage('tasks');
  }

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> select(String table, {Map<String, dynamic>? where}) async {
    final data = _memoryData[table] ?? [];
    
    if (where == null) return List.from(data);
    
    return data.where((item) {
      return where.entries.every((entry) => item[entry.key] == entry.value);
    }).toList();
  }

  Future<Map<String, dynamic>?> selectSingle(String table, {required Map<String, dynamic> where}) async {
    final results = await select(table, where: where);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    data['createdAt'] = DateTime.now().toIso8601String();
    
    _memoryData[table]!.add(data);
    await _saveToStorage(table);
    
    return data;
  }

  Future<bool> update(String table, Map<String, dynamic> data, {required Map<String, dynamic> where}) async {
    final items = _memoryData[table]!;
    bool updated = false;
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (where.entries.every((entry) => item[entry.key] == entry.value)) {
        items[i] = {...item, ...data, 'updatedAt': DateTime.now().toIso8601String()};
        updated = true;
      }
    }
    
    if (updated) {
      await _saveToStorage(table);
    }
    
    return updated;
  }

  Future<bool> delete(String table, {required Map<String, dynamic> where}) async {
    final items = _memoryData[table]!;
    final originalLength = items.length;
    
    items.removeWhere((item) {
      return where.entries.every((entry) => item[entry.key] == entry.value);
    });
    
    if (items.length != originalLength) {
      await _saveToStorage(table);
      return true;
    }
    
    return false;
  }

  // Authentication methods
  Future<Map<String, dynamic>?> authenticateUser(String userId, String password) async {
    final user = await selectSingle('users', where: {'userId': userId, 'password': password});
    return user;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await selectSingle('users', where: {'id': id});
  }

  // Request management
  Future<List<Map<String, dynamic>>> getUserRequests(String userId) async {
    return await select('requests', where: {'userId': userId});
  }

  Future<List<Map<String, dynamic>>> getAllRequests() async {
    return await select('requests');
  }

  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> requestData) async {
    // Set default status if not provided
    if (!requestData.containsKey('status')) {
      requestData['status'] = 'pending';
    }
    
    print('Database createRequest: $requestData'); // Debug
    final result = await insert('requests', requestData);
    print('Database createRequest result: $result'); // Debug
    
    return result;
  }

  // Task management
  Future<List<Map<String, dynamic>>> getTechnicianTasks(String technicianId) async {
    return await select('tasks', where: {'technicianId': technicianId});
  }

  Future<Map<String, dynamic>> assignTask(String requestId, String technicianId) async {
    // Update the original request with assigned technician and status
    await update('requests', {
      'assignedTechnicianId': technicianId,
      'status': 'assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    }, where: {'id': requestId});
    
    // Also create a task record for tracking
    return await insert('tasks', {
      'requestId': requestId,
      'technicianId': technicianId,
      'status': 'assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    });
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    for (String table in _memoryData.keys) {
      _memoryData[table]!.clear();
      await prefs.remove(table);
    }
    print('✅ All data cleared from local database');
  }

  // Clear only requests and tasks (keep users)
  Future<void> clearRequestsAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _memoryData['requests']!.clear();
    _memoryData['tasks']!.clear();
    await prefs.remove('requests');
    await prefs.remove('tasks');
    print('✅ Requests and tasks cleared from local database');
  }
}
