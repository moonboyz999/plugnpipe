import 'package:flutter/foundation.dart';

class UserDataService extends ChangeNotifier {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // User data fields
  String _fullName = 'Student User';
  String _email = 'student@university.edu';
  String _phoneNumber = '+1 (555) 987-6543';
  String _studentId = 'STU001';
  String? _profileImagePath;

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get studentId => _studentId;
  String? get profileImagePath => _profileImagePath;

  // Update methods
  void updateFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void updatePhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void updateStudentId(String id) {
    _studentId = id;
    notifyListeners();
  }

  void updateProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  // Save all user data at once
  void updateUserData({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? studentId,
    String? profileImagePath,
  }) {
    if (fullName != null) _fullName = fullName;
    if (email != null) _email = email;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (studentId != null) _studentId = studentId;
    if (profileImagePath != null) _profileImagePath = profileImagePath;

    notifyListeners();
  }
}
