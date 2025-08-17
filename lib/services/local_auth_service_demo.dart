class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  // Current user info
  Map<String, dynamic>? _currentUser;

  // Predefined accounts for all roles
  final Map<String, Map<String, dynamic>> _accounts = {
    // Student accounts
    'student@test.com': {
      'id': 'student_001',
      'userId': 'student_001',  // Added for compatibility
      'email': 'student@test.com',
      'password': 'student123',
      'name': 'Test Student',
      'role': 'student',
      'student_id': 'STU001',
      'building': 'Dormitory A',
      'room_number': '205',
      'phone': '+60123456789',
    },
    'alice@student.com': {
      'id': 'student_002',
      'userId': 'student_002',  // Added for compatibility
      'email': 'alice@student.com',
      'password': 'password',
      'name': 'Alice Johnson',
      'role': 'student',
      'student_id': 'STU002',
      'building': 'Dormitory B',
      'room_number': '101',
      'phone': '+60123456788',
    },

    // Technician accounts
    'tech@test.com': {
      'id': 'tech_001',
      'userId': 'tech_001',  // Added for compatibility
      'email': 'tech@test.com',
      'password': 'tech123',
      'name': 'Test Technician',
      'role': 'technician',
      'employee_id': 'TECH001',
      'specialization': 'General Maintenance',
      'phone': '+60123456787',
      'experience_years': 5,
    },
    'john@tech.com': {
      'id': 'tech_002',
      'userId': 'tech_002',  // Added for compatibility
      'email': 'john@tech.com',
      'password': 'password',
      'name': 'John Smith',
      'role': 'technician',
      'employee_id': 'TECH002',
      'specialization': 'Plumbing',
      'phone': '+60123456786',
      'experience_years': 8,
    },

    // Admin accounts
    'admin@test.com': {
      'id': 'admin_001',
      'userId': 'admin_001',  // Added for compatibility
      'email': 'admin@test.com',
      'password': 'admin123',
      'name': 'Test Admin',
      'role': 'admin',
      'employee_id': 'ADM001',
      'department': 'Facilities Management',
      'phone': '+60123456785',
      'permissions': ['all'],
    },
    'manager@admin.com': {
      'id': 'admin_002',
      'userId': 'admin_002',  // Added for compatibility
      'email': 'manager@admin.com',
      'password': 'password',
      'name': 'Sarah Manager',
      'role': 'admin',
      'employee_id': 'ADM002',
      'department': 'Operations',
      'phone': '+60123456784',
      'permissions': ['reports', 'users', 'tasks'],
    },
  };

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Get current user
  Map<String, dynamic>? get currentUser => _currentUser;

  // Get current user email
  String? get currentUserEmail => _currentUser?['email'];

  // Get current user role
  String? get currentUserRole => _currentUser?['role'];

  // Get current user name
  String? get currentUserName => _currentUser?['name'];

  // Get all accounts
  Map<String, Map<String, dynamic>> get accounts => _accounts;

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final account = _accounts[email.toLowerCase()];
      if (account != null && account['password'] == password) {
        _currentUser = Map<String, dynamic>.from(account);
        _currentUser!.remove('password'); // Don't store password
        print(
          '✅ Local login successful: ${account['name']} (${account['role']})',
        );
        return true;
      } else {
        print('❌ Invalid credentials');
        return false;
      }
    } catch (e) {
      print('❌ Local sign in error: $e');
      return false;
    }
  }

  // Sign up (for demo, just add to accounts)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (_accounts.containsKey(email.toLowerCase())) {
        print('❌ Account already exists');
        return false;
      }

      final newAccount = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'email': email.toLowerCase(),
        'password': password,
        'name': name,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      };

      _accounts[email.toLowerCase()] = newAccount;
      print('✅ Account created: $name ($role)');
      return true;
    } catch (e) {
      print('❌ Local sign up error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    print('✅ Signed out successfully');
  }

  // Reset password (demo - just print message)
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('✅ Demo: Password reset email would be sent to: $email');
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    return _currentUser;
  }

  // Get current user (for compatibility with main.dart)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return _currentUser;
  }

  // Update profile
  Future<void> updateProfile({String? name, Map<String, dynamic>? data}) async {
    if (_currentUser != null) {
      final email = _currentUser!['email'];
      
      if (name != null) {
        _currentUser!['name'] = name;
      }
      if (data != null) {
        _currentUser!.addAll(data);
      }
      
      // Also update the original account in the accounts map
      if (email != null && _accounts.containsKey(email)) {
        if (name != null) {
          _accounts[email]!['name'] = name;
        }
        if (data != null) {
          _accounts[email]!.addAll(data);
        }
      }
      
      print('✅ Profile updated for ${_currentUser!['name']}');
    }
  }

  // Utility method to print all demo accounts for reference
  void printDemoAccounts() {
    print('\n📋 Available Demo Accounts:');
    print('════════════════════════════════════════');

    print('\n👨‍🎓 STUDENT ACCOUNTS:');
    _accounts.entries.where((e) => e.value['role'] == 'student').forEach((
      entry,
    ) {
      print('  Email: ${entry.key}');
      print('  Password: ${entry.value['password']}');
      print('  Name: ${entry.value['name']}');
      print('  ───────────────────────');
    });

    print('\n🔧 TECHNICIAN ACCOUNTS:');
    _accounts.entries.where((e) => e.value['role'] == 'technician').forEach(
      (entry) {
        print('  Email: ${entry.key}');
        print('  Password: ${entry.value['password']}');
        print('  Name: ${entry.value['name']}');
        print('  ───────────────────────');
      },
    );

    print('\n👨‍💼 ADMIN ACCOUNTS:');
    _accounts.entries.where((e) => e.value['role'] == 'admin').forEach((
      entry,
    ) {
      print('  Email: ${entry.key}');
      print('  Password: ${entry.value['password']}');
      print('  Name: ${entry.value['name']}');
      print('  ───────────────────────');
    });

    print('════════════════════════════════════════\n');
  }
}
