import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoAssignTasks = false;
  bool _requireApproval = true;
  String _selectedTheme = 'light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                children: [
                  Icon(Icons.settings, size: 32, color: Color(0xFFFFA726)),
                  SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // System Settings Section
              _buildSettingsSection(
                title: 'System Settings',
                children: [
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications for new reports and tasks',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Auto-assign Tasks',
                    subtitle:
                        'Automatically assign tasks to available technicians',
                    value: _autoAssignTasks,
                    onChanged: (value) {
                      setState(() {
                        _autoAssignTasks = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Require Report Approval',
                    subtitle:
                        'Reports must be approved before marking as complete',
                    value: _requireApproval,
                    onChanged: (value) {
                      setState(() {
                        _requireApproval = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSettingsSection(
                title: 'Appearance',
                children: [
                  _buildDropdownTile(
                    title: 'Theme',
                    subtitle: 'Choose your preferred theme',
                    value: _selectedTheme,
                    options: [
                      {'value': 'light', 'label': 'Light'},
                      {'value': 'dark', 'label': 'Dark'},
                      {'value': 'system', 'label': 'System'},
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Data Management Section
              _buildSettingsSection(
                title: 'Data Management',
                children: [
                  _buildActionTile(
                    title: 'Export Data',
                    subtitle: 'Export reports and user data',
                    icon: Icons.download,
                    onTap: () {
                      _showComingSoonSnackBar('Export Data');
                    },
                  ),
                  _buildActionTile(
                    title: 'Backup Database',
                    subtitle: 'Create a backup of the system database',
                    icon: Icons.backup,
                    onTap: () {
                      _showBackupDialog();
                    },
                  ),
                  _buildActionTile(
                    title: 'Clear Cache',
                    subtitle: 'Clear system cache and temporary files',
                    icon: Icons.clear_all,
                    onTap: () {
                      _showClearCacheDialog();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Security Section
              _buildSettingsSection(
                title: 'Security',
                children: [
                  _buildActionTile(
                    title: 'Change Password',
                    subtitle: 'Update your admin password',
                    icon: Icons.lock,
                    onTap: () {
                      _showComingSoonSnackBar('Change Password');
                    },
                  ),
                  _buildActionTile(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Enable 2FA for enhanced security',
                    icon: Icons.security,
                    onTap: () {
                      _showComingSoonSnackBar('Two-Factor Authentication');
                    },
                  ),
                  _buildActionTile(
                    title: 'Session Management',
                    subtitle: 'Manage active user sessions',
                    icon: Icons.devices,
                    onTap: () {
                      _showComingSoonSnackBar('Session Management');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSettingsSection(
                title: 'About',
                children: [
                  _buildInfoTile(title: 'App Version', subtitle: '1.0.0'),
                  _buildInfoTile(
                    title: 'Last Updated',
                    subtitle: 'August 10, 2025',
                  ),
                  _buildActionTile(
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    icon: Icons.description,
                    onTap: () {
                      _showComingSoonSnackBar('Terms of Service');
                    },
                  ),
                  _buildActionTile(
                    title: 'Privacy Policy',
                    subtitle: 'View privacy policy',
                    icon: Icons.privacy_tip,
                    onTap: () {
                      _showComingSoonSnackBar('Privacy Policy');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFFA726),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option['value'],
            child: Text(option['label']!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFA726)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({required String title, required String subtitle}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Backup Database'),
          content: const Text(
            'This will create a backup of all system data. This process may take a few minutes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
              ),
              child: const Text(
                'Start Backup',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'This will clear all temporary files and cache. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Clear Cache',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFFFFA726),
      ),
    );
  }
}
