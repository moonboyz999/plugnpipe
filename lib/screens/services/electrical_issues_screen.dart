import 'package:flutter/material.dart';
import 'electrical_schedule_screen.dart';

class ElectricalIssuesScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  final String floor;
  final String room;

  const ElectricalIssuesScreen({
    super.key,
    required this.location,
    required this.serviceType,
    required this.floor,
    required this.room,
  });

  @override
  State<ElectricalIssuesScreen> createState() => _ElectricalIssuesScreenState();
}

class _ElectricalIssuesScreenState extends State<ElectricalIssuesScreen> {
  final List<Map<String, dynamic>> _issues = [
    {'text': 'Power outage', 'selected': false},
    {'text': 'Circuit breaker tripping', 'selected': false},
    {'text': 'Electrical outlets not working', 'selected': false},
    {'text': 'Light fixtures malfunction', 'selected': false},
    {'text': 'Wiring problems', 'selected': false},
    {'text': 'Electrical panel issues', 'selected': false},
    {'text': 'Sparking outlets or switches', 'selected': false},
    {'text': 'Electrical installation needed', 'selected': false},
    {'text': 'Urgent electrical repair', 'selected': false},
    {'text': 'Other electrical issues', 'selected': false},
  ];

  List<String> get _selectedIssues => _issues
      .where((issue) => issue['selected'])
      .map((issue) => issue['text'] as String)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Electrical Issues',
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
              'What electrical issues are you experiencing?',
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          issue['selected'] = !issue['selected'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: issue['selected']
                                ? const Color(0xFFFFA726)
                                : Colors.grey[300]!,
                            width: issue['selected'] ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: issue['selected'],
                              onChanged: (value) {
                                setState(() {
                                  issue['selected'] = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFFFFA726),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                issue['text'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: issue['selected']
                                      ? const Color(0xFFFFA726)
                                      : Colors.black87,
                                  fontWeight: issue['selected']
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Continue button
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElectricalScheduleScreen(
                              location: widget.location,
                              serviceType: widget.serviceType,
                              issues: _selectedIssues,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  'Continue (${_selectedIssues.length} selected)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
