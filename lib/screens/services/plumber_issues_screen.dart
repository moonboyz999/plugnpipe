import 'package:flutter/material.dart';
import 'plumber_schedule_screen.dart';

class PlumberIssuesScreen extends StatefulWidget {
  final String location;
  final String serviceType;

  const PlumberIssuesScreen({
    super.key,
    required this.location,
    required this.serviceType,
  });

  @override
  State<PlumberIssuesScreen> createState() => _PlumberIssuesScreenState();
}

class _PlumberIssuesScreenState extends State<PlumberIssuesScreen> {
  final List<String> _issues = [
    'Leaky pipes',
    'Clogged drains',
    'Toilet not working',
    'Low water pressure',
    'Water heater issues',
    'Faucet problems',
    'Pipe burst',
    'Sewage backup',
    'Installation needed',
    'Other plumbing issue',
  ];

  final Set<String> _selectedIssues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plumber Issues',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What plumbing issues are you experiencing?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select all that apply:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Issues list
            Expanded(
              child: ListView.builder(
                itemCount: _issues.length,
                itemBuilder: (context, index) {
                  final issue = _issues[index];
                  return CheckboxListTile(
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
                    activeColor: const Color(0xFFFFA726),
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIssues.isNotEmpty
                      ? const Color(0xFFFFA726)
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
                            builder: (context) => PlumberScheduleScreen(
                              location: widget.location,
                              serviceType: widget.serviceType,
                              issues: _selectedIssues.toList(),
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
