import 'package:flutter/material.dart';
import 'fridge_repair_schedule_screen.dart';

class FridgeRepairIssueScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  const FridgeRepairIssueScreen({
    super.key,
    required this.location,
    required this.serviceType,
  });

  @override
  State<FridgeRepairIssueScreen> createState() =>
      _FridgeRepairIssueScreenState();
}

class _FridgeRepairIssueScreenState extends State<FridgeRepairIssueScreen> {
  final List<String> _issues = [
    'Not cooling properly',
    'Freezer not working',
    'Strange noises',
    'Water leaking',
    'Door seal problems',
    'Temperature control issues',
    'Compressor problems',
  ];
  final Set<String> _selectedIssues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge Repair Service'),
        backgroundColor: const Color(0xFFFFA726),
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
                      ? Colors.orange
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
                            builder: (context) {
                              return FridgeRepairScheduleScreen(
                                location: widget.location,
                                serviceType: widget.serviceType,
                                issues: _selectedIssues.toList(),
                              );
                            },
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
