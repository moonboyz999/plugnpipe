import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../student/student_main_scaffold.dart';
import '../tech/tech_main_scaffold.dart';
import '../admin/admin_main_scaffold.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
// Removed backend auth services; using permissive local auth logic only.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'User ID and password are required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simulate a brief loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Hardcoded authentication - accept any credentials
      bool success = true; // Always succeed
      String role = 'student'; // Default to student role

      // Check role based on email pattern
      if (email.toLowerCase().contains('tech')) {
        role = 'technician';
      } else if (email.toLowerCase().contains('admin')) {
        role = 'admin';
      }

      if (success && mounted) {
        // Navigate to appropriate screen based on role
        Widget homeScreen;
        switch (role) {
          case 'technician':
            homeScreen = const TechMainScaffold();
            break;
          case 'admin':
            homeScreen = const AdminMainScaffold();
            break;
          default:
            homeScreen = const StudentMainScaffold();
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => homeScreen),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFA726), // Orange (same as register)
              Color(0xFFFFD600), // Yellow (same as register)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo Section
                SvgPicture.asset(
                  'assets/images/Logo.svg',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 40),
                // Subtitle
                const Text(
                  'Enter Your User ID for\nVerification',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 40),
                // Form Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User ID Label and Field
                    const Text(
                      'USER ID:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Enter your user ID',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Password Label and Field
                    const Text(
                      'PASSWORD:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Register Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register For new User',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 8),
                    // LOGIN Button
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Reset Password Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _errorMessage.contains('Success') ||
                                  _errorMessage.contains('successful')
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _errorMessage.contains('Success') ||
                                    _errorMessage.contains('successful')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color:
                                _errorMessage.contains('Success') ||
                                    _errorMessage.contains('successful')
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
