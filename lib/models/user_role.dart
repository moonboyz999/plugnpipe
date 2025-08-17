enum UserRole { student, technician, admin }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.technician:
        return 'technician';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
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
}
