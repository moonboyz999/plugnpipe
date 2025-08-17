import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_role.dart';

class LocalAuthService extends ChangeNotifier {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  SharedPreferences? _prefs;
  Map<String, dynamic>? _currentUser;
  UserRole? _userRole;
  List<Map<String, dynamic>> _localUsers = [];

  bool get isAuthenticated => _currentUser != null;
  Map<String, dynamic>? get currentUserDoc => _currentUser;
  UserRole? get userRole => _userRole;
  String? get currentUserUid => _currentUser?['userId'];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLocalUsers();
    
    // Create default users if none exist
    await createDefaultUsers();
    
    if (kDebugMode) {
      print(
        'LocalAuthService initialized (local users: ${_localUsers.length})',
      );
    }
  }

  Future<void> _loadLocalUsers() async {
    final usersJson = _prefs?.getString('local_users') ?? '[]';
    _localUsers = List<Map<String, dynamic>>.from(json.decode(usersJson));
  }

  Future<void> _saveLocalUsers() async {
    await _prefs?.setString('local_users', json.encode(_localUsers));
  }

  Future<void> createDefaultUsers() async {
    if (kDebugMode) {
      print('🔄 Checking if default users need to be created. Current users: ${_localUsers.length}');
    }
    
    if (_localUsers.isEmpty) {
      if (kDebugMode) {
        print('🔄 Creating default users...');
      }
      
      await registerLocalUser(
        userId: 'student123',
        password: 'password123',
        name: 'Student User',
        phone: '+6012345677',
        role: UserRole.student,
      );

      await registerLocalUser(
        userId: 'tech123',
        password: 'password123',
        name: 'Technician User',
        phone: '6012345677',
        role: UserRole.technician,
      );

      await registerLocalUser(
        userId: 'admin123',
        password: 'password123',
        name: 'Admin User',
        phone: '6012345677',
        role: UserRole.admin,
      );

      if (kDebugMode) {
        print(
          '✅ Created default users: student123, tech123, admin123 (all password: password123)',
        );
        print('📊 Total users now: ${_localUsers.length}');
      }
    } else {
      if (kDebugMode) {
        print('✅ Default users already exist: ${_localUsers.length} users');
      }
    }
  }

  Future<bool> registerLocalUser({
    required String userId,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      // Check if user already exists
      final existingUser = _localUsers.firstWhere(
        (user) => user['userId'] == userId,
        orElse: () => <String, dynamic>{},
      );

      if (existingUser.isNotEmpty) {
        if (kDebugMode) print('User $userId already exists');
        return false;
      }

      // Create new user
      final newUser = {
        'userId': userId,
        'password': password, // In production, this should be hashed
        'name': name,
        'phone': phone,
        'role': role.name,
        'createdAt': DateTime.now().toIso8601String(),
      };

      _localUsers.add(newUser);
      await _saveLocalUsers();

      if (kDebugMode) print('User $userId registered successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('Failed to register user: $e');
      return false;
    }
  }

  Future<bool> register(
    String userId,
    String password,
    String name, {
    UserRole role = UserRole.student,
  }) async {
    return await registerLocalUser(
      userId: userId,
      password: password,
      name: name,
      phone: '', // Optional phone for registration
      role: role,
    );
  }

  Future<bool> login(String userId, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 Login attempt for userId: $userId');
        print('📊 Available users: ${_localUsers.length}');
        for (var user in _localUsers) {
          print('   - ${user['userId']} (${user['role']})');
        }
      }
      
      // Check local users first
      final user = _localUsers.firstWhere(
        (user) => user['userId'] == userId && user['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (user.isNotEmpty) {
        _currentUser = user;
        _userRole = _getUserRoleFromString(user['role']);

        // Save login state
        await _prefs?.setString('current_user', json.encode(user));

        notifyListeners();
        if (kDebugMode) print('✅ Login successful for user: $userId');
        return true;
      }

      if (kDebugMode) print('❌ Login failed for user: $userId');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _userRole = null;
    await _prefs?.remove('current_user');
    notifyListeners();
    if (kDebugMode) print('User logged out');
  }

  UserRole _getUserRoleFromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'technician':
        return UserRole.technician;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  // Restore login state on app restart
  Future<void> restoreLoginState() async {
    final userJson = _prefs?.getString('current_user');
    if (userJson != null) {
      _currentUser = json.decode(userJson);
      _userRole = _getUserRoleFromString(_currentUser!['role']);
      notifyListeners();
      if (kDebugMode) {
        print('Login state restored for: ${_currentUser!['userId']}');
      }
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    
    // Try to restore from SharedPreferences
    final userJson = _prefs?.getString('current_user');
    if (userJson != null) {
      _currentUser = json.decode(userJson);
      _userRole = _getUserRoleFromString(_currentUser!['role']);
      return _currentUser;
    }
    
    return null;
  }

  // Update current user data and persist changes
  Future<bool> updateCurrentUserData(Map<String, dynamic> updatedData) async {
    try {
      if (_currentUser == null) return false;

      // Find user in local storage and update
      final userIndex = _localUsers.indexWhere(
        (user) => user['userId'] == _currentUser!['userId']
      );

      if (userIndex != -1) {
        // Update the user in local storage
        _localUsers[userIndex] = {..._localUsers[userIndex], ...updatedData};
        
        // Update current user reference
        _currentUser = _localUsers[userIndex];
        
        // Save to SharedPreferences
        await _saveLocalUsers();
        await _prefs?.setString('current_user', json.encode(_currentUser));
        
        notifyListeners();
        if (kDebugMode) {
          print('User data updated for: ${_currentUser!['userId']}');
        }
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) print('Error updating user data: $e');
      return false;
    }
  }
}
