import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_main_scaffold.dart';
import 'screens/tech/tech_main_scaffold.dart';
import 'screens/admin/admin_main_scaffold.dart';
import 'services/local_database.dart';
import 'services/local_auth_service.dart';
import 'utils/database_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Database
  await LocalDatabase.instance.initialize();

  // Clear old sample data to avoid confusion with real requests
  await DatabaseUtils.clearSampleData();

  if (kDebugMode) print('✅ Local Database initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plug-N-Pipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocalAuthService _authService = LocalAuthService();
  Widget? _initialScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        if (kDebugMode) print('🔄 No user logged in, showing login screen');
        setState(() {
          _initialScreen = const LoginScreen();
          _isLoading = false;
        });
        return;
      }

      if (kDebugMode) print('✅ User logged in: ${currentUser['userId']}');

      // Get user role and navigate to appropriate screen
      final userRole = currentUser['role'];
      Widget homeScreen;

      switch (userRole?.toLowerCase()) {
        case 'student':
          homeScreen = const StudentMainScaffold();
          if (kDebugMode) print('🎓 Navigating to Student Dashboard');
          break;
        case 'technician':
          homeScreen = const TechMainScaffold();
          if (kDebugMode) print('🔧 Navigating to Technician Dashboard');
          break;
        case 'admin':
          homeScreen = const AdminMainScaffold();
          if (kDebugMode) print('👑 Navigating to Admin Dashboard');
          break;
        default:
          // Default to student if role is unclear
          homeScreen = const StudentMainScaffold();
          if (kDebugMode) print('🎓 Default: Navigating to Student Dashboard');
      }

      setState(() {
        _initialScreen = homeScreen;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('❌ Error determining initial screen: $e');
      setState(() {
        _initialScreen = const LoginScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFA726), // Orange
                Color(0xFFFFD600), // Yellow
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _initialScreen ?? const LoginScreen();
  }
}
