import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class StudentNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const StudentNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown.withValues(alpha: 0.6),
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        iconSize: 32,
        showUnselectedLabels: true,
        items: [
          _navItem(Icons.home, 'Home', currentIndex == 0),
          _chatNavItem(currentIndex == 1),
          _notificationNavItem(currentIndex == 2, isStudent: true),
          _navItem(Icons.person, 'Profile', currentIndex == 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool selected) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _chatNavItem(bool selected) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder<int>(
          valueListenable: ChatService().unreadCount,
          builder: (context, unreadCount, child) {
            return Stack(
              children: [
                const Icon(Icons.chat),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      label: 'Chat',
    );
  }

  BottomNavigationBarItem _notificationNavItem(bool selected, {bool isStudent = false}) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder<int>(
          valueListenable: NotificationService().unreadCount,
          builder: (context, unreadCount, child) {
            return Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      label: 'Notifications',
    );
  }
}

class TechNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const TechNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown.withValues(alpha: 0.6),
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        iconSize: 32,
        showUnselectedLabels: true,
        items: [
          _navItem(Icons.home, 'Home', currentIndex == 0),
          _navItem(Icons.assignment, 'Tasks', currentIndex == 1),
          _notificationNavItem(currentIndex == 2, isStudent: false),
          _navItem(Icons.person, 'Profile', currentIndex == 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool selected) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _notificationNavItem(bool selected, {bool isStudent = false}) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder<int>(
          valueListenable: NotificationService().unreadCount,
          builder: (context, unreadCount, child) {
            return Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      label: 'Notifications',
    );
  }
}

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown.withValues(alpha: 0.6),
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        iconSize: 32,
        showUnselectedLabels: true,
        items: [
          _navItem(Icons.dashboard, 'Dashboard', currentIndex == 0),
          _navItem(Icons.people, 'Users', currentIndex == 1),
          _notificationNavItem(currentIndex == 2, isStudent: false),
          _navItem(Icons.assessment, 'Reports', currentIndex == 3),
          _navItem(Icons.person, 'Profile Settings', currentIndex == 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool selected) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _notificationNavItem(bool selected, {bool isStudent = false}) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder<int>(
          valueListenable: NotificationService().unreadCount,
          builder: (context, unreadCount, child) {
            return Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      label: 'Notifications',
    );
  }
}
