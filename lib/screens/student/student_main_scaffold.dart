import 'package:flutter/material.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'student_home_screen.dart';
import '../support/support_chat_screen.dart';
import '../common/notification_screen.dart';
import '../profile/student_profile_screen.dart';

class StudentMainScaffold extends StatefulWidget {
  const StudentMainScaffold({super.key});

  @override
  State<StudentMainScaffold> createState() => _StudentMainScaffoldState();
}

class _StudentMainScaffoldState extends State<StudentMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentHomeScreen(),
    SupportChatScreen(),
    NotificationScreen(),
    StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: StudentNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
