import 'package:flutter/material.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'tech_home_screen.dart';
import 'tech_notification_screen.dart';
import 'tech_profile_screen.dart';
import 'assigned_tasks_screen.dart';

class TechMainScaffold extends StatefulWidget {
  const TechMainScaffold({super.key});

  @override
  State<TechMainScaffold> createState() => _TechMainScaffoldState();
}

class _TechMainScaffoldState extends State<TechMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TechHomeScreen(), // Index 0: Home
    const AssignedTasksScreen(), // Index 1: Tasks
    const TechNotificationScreen(), // Index 2: Notifications
    const TechProfileScreen(), // Index 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: TechNavBar(
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
