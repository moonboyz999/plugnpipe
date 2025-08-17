import 'package:flutter/foundation.dart';
import '../services/local_auth_service.dart';

class UserDataService extends ChangeNotifier {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final LocalAuthService _authService = LocalAuthService();

  // Cache for profile image path (per user)
  String? _profileImagePath;

  // Getters that fetch data from current logged-in user
  String get fullName {
    final user = _authService.currentUserDoc;
    return user?['name'] ?? 'User';
  }

  String get email {
    final user = _authService.currentUserDoc;
    return user?['email'] ?? user?['userId'] ?? 'user@email.com';
  }

  String get phoneNumber {
    final user = _authService.currentUserDoc;
    return user?['phone'] ?? '+1 (555) 000-0000';
  }

  String get studentId {
    final user = _authService.currentUserDoc;
    // Return appropriate ID based on role
    return user?['student_id'] ?? user?['employee_id'] ?? user?['userId'] ?? 'ID001';
  }

  String? get profileImagePath => _profileImagePath;

  // Update methods now save to the database via auth service
  Future<void> updateFullName(String name) async {
    final user = _authService.currentUserDoc;
    if (user != null) {
      user['name'] = name;
      await _saveUserData(user);
    }
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    final user = _authService.currentUserDoc;
    if (user != null) {
      user['email'] = email;
      await _saveUserData(user);
    }
    notifyListeners();
  }

  Future<void> updatePhoneNumber(String phone) async {
    final user = _authService.currentUserDoc;
    if (user != null) {
      user['phone'] = phone;
      await _saveUserData(user);
    }
    notifyListeners();
  }

  Future<void> updateStudentId(String id) async {
    final user = _authService.currentUserDoc;
    if (user != null) {
      // Update appropriate ID field based on role
      final role = user['role'];
      if (role == 'student') {
        user['student_id'] = id;
      } else {
        user['employee_id'] = id;
      }
      await _saveUserData(user);
    }
    notifyListeners();
  }

  void updateProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  // Save all user data at once
  Future<void> updateUserData({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? studentId,
    String? profileImagePath,
  }) async {
    final user = _authService.currentUserDoc;
    if (user != null) {
      if (fullName != null) user['name'] = fullName;
      if (email != null) user['email'] = email;
      if (phoneNumber != null) user['phone'] = phoneNumber;
      if (studentId != null) {
        final role = user['role'];
        if (role == 'student') {
          user['student_id'] = studentId;
        } else {
          user['employee_id'] = studentId;
        }
      }
      await _saveUserData(user);
    }
    if (profileImagePath != null) _profileImagePath = profileImagePath;

    notifyListeners();
  }

  // Private method to save user data back to auth service
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    bool success = await _authService.updateCurrentUserData(userData);
    if (kDebugMode) {
      print('UserDataService: Update result: $success for user ${userData['name']}');
      print('UserDataService: Updated data: $userData');
    }
  }
}
