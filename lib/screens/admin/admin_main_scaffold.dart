import 'package:flutter/material.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'admin_home_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_technicians_screen.dart';
import 'admin_profile_screen.dart';

class AdminMainScaffold extends StatefulWidget {
  const AdminMainScaffold({super.key});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(), // Index 0: Home
    const AdminReportsScreen(), // Index 1: Reports
    const AdminTechniciansScreen(), // Index 2: Technicians
    const AdminProfileScreen(), // Index 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AdminNavBar(
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
