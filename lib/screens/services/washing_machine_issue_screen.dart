import 'package:flutter/material.dart';
import 'washing_machine_schedule_screen.dart';

class WashingMachineIssueScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  const WashingMachineIssueScreen({
    super.key,
    required this.location,
    required this.serviceType,
  });

  @override
  State<WashingMachineIssueScreen> createState() =>
      _WashingMachineIssueScreenState();
}

class _WashingMachineIssueScreenState extends State<WashingMachineIssueScreen> {
  final List<String> _issues = [
    'Drum and motor issues',
    'Pump and valve replacement',
    'Electronic control repairs',
    'Water leak fixes',
    'Door seal replacements',
    'Spin cycle problems',
    'Noise and vibration diagnosis',
    'Energy efficiency optimization',
    'Other',
  ];
  final Set<String> _selectedIssues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Washing Machine Repair Service'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What issues are you experiencing?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._issues.map(
              (issue) => CheckboxListTile(
                title: Text(issue),
                value: _selectedIssues.contains(issue),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedIssues.add(issue);
                    } else {
                      _selectedIssues.remove(issue);
                    }
                  });
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIssues.isNotEmpty
                      ? Colors.blue
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _selectedIssues.isNotEmpty
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WashingMachineScheduleScreen(
                              location: widget.location,
                              serviceType: widget.serviceType,
                              issues: _selectedIssues.toList(),
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
