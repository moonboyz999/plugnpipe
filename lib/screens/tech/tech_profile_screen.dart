import 'package:flutter/material.dart';
import '../../services/user_data_service.dart';
import 'tech_edit_profile_screen.dart';
import '../auth/login_screen.dart';
import '../profile/settings_screen.dart';
import '../support/help_support_screen.dart';
import '../support/privacy_policy_screen.dart';

class TechProfileScreen extends StatefulWidget {
  const TechProfileScreen({super.key});

  @override
  State<TechProfileScreen> createState() => _TechProfileScreenState();
}

class _TechProfileScreenState extends State<TechProfileScreen> {
  final UserDataService _userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _userDataService.addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    _userDataService.removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    setState(() {
      // Refresh the UI when user data changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Manage your account',
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _userDataService.profileImagePath != null
                          ? ClipOval(
                              child: Image.asset(
                                _userDataService.profileImagePath!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.engineering,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userDataService.fullName.isNotEmpty
                                ? _userDataService.fullName
                                : 'Tech User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userDataService.email.isNotEmpty
                                ? _userDataService.email
                                : 'tech@plugnpipe.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TechEditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFA726)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFFFA726)),
                    title: const Text('Personal Information'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TechEditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFFFFA726)),
                    title: const Text('Phone Number'),
                    subtitle: Text(
                      _userDataService.phoneNumber.isNotEmpty
                          ? _userDataService.phoneNumber
                          : '+1234567890',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFFFFA726)),
                    title: const Text('Email'),
                    subtitle: Text(
                      _userDataService.email.isNotEmpty
                          ? _userDataService.email
                          : 'tech@plugnpipe.com',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.engineering,
                      color: Color(0xFFFFA726),
                    ),
                    title: const Text('Technician ID'),
                    subtitle: Text(
                      _userDataService.studentId.isNotEmpty
                          ? _userDataService.studentId
                          : 'TECH001',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.work, color: Color(0xFFFFA726)),
                    title: const Text('Department'),
                    subtitle: const Text('Maintenance & Repair'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.home, color: Color(0xFFFFA726)),
                    title: const Text('Additional Info'),
                    subtitle: const Text('Tap to edit additional information'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TechEditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color(0xFFFFA726),
                    ),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFFFFA726)),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip,
                      color: Color(0xFFFFA726),
                    ),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
