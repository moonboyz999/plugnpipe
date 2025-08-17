import 'package:flutter/material.dart';
import '../profile/student_profile_screen.dart';
import '../services/fridge_repair_screen.dart';
import '../services/washing_machine_repair_screen.dart';
import '../services/plumber_request_screen.dart';
import '../services/electrical_request_screen.dart';
import '../services/emergency_repair_screen.dart';
import 'my_requests_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentProfileScreen(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.orange),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Hi ! Student',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Service Request Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.home_repair_service,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Service Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Services Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _ServiceCard(
                        title: 'Fridge Repair',
                        icon: Icons.kitchen,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FridgeRepairScreen(),
                          ),
                        ),
                      ),
                      _ServiceCard(
                        title: 'Plumber',
                        icon: Icons.plumbing,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlumberRequestScreen(),
                          ),
                        ),
                      ),
                      _ServiceCard(
                        title: 'Electrical and Wiring',
                        icon: Icons.electrical_services,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ElectricalRequestScreen(),
                          ),
                        ),
                      ),
                      _ServiceCard(
                        title: 'Washing Machine',
                        icon: Icons.local_laundry_service,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WashingMachineRepairScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // My Requests card as a single row
                  SizedBox(
                    width: double.infinity,
                    child: _ServiceCard(
                      title: 'My Requests',
                      icon: Icons.assignment_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyRequestsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Urgent Services Section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[600], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Urgent Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: _EmergencyButton(
                      icon: Icons.build_circle,
                      label: 'Urgent Repair',
                      phoneNumber: '+60 12-345-6789',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  const _ServiceCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String phoneNumber;
  final Color color;

  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.phoneNumber,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'Urgent Repair') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UrgentRepairScreen()),
          );
        } else {
          _showEmergencyDialog(context);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              phoneNumber,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Emergency Contact: $phoneNumber'),
              const SizedBox(height: 16),
              const Text(
                'This will initiate an emergency call. Only use for genuine emergencies.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makeEmergencyCall(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Call Now'),
            ),
          ],
        );
      },
    );
  }

  void _makeEmergencyCall(BuildContext context) {
    // In a real app, you would use url_launcher package to make phone calls
    // For now, we'll show a snackbar with the phone number
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency call to $phoneNumber initiated'),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
