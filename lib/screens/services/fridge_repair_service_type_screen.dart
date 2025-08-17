import 'package:flutter/material.dart';
import 'fridge_repair_issue_screen.dart';

class FridgeRepairServiceTypeScreen extends StatefulWidget {
  final String location;
  const FridgeRepairServiceTypeScreen({super.key, required this.location});

  @override
  State<FridgeRepairServiceTypeScreen> createState() =>
      _FridgeRepairServiceTypeScreenState();
}

class _FridgeRepairServiceTypeScreenState
    extends State<FridgeRepairServiceTypeScreen> {
  String? _selectedType;

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
              'What type of service do you need?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ServiceTypeOption(
              title: 'Repair',
              selected: _selectedType == 'Repair',
              onTap: () {
                setState(() {
                  _selectedType = 'Repair';
                });
              },
            ),
            _ServiceTypeOption(
              title: 'Installation',
              selected: _selectedType == 'Installation',
              onTap: () {
                setState(() {
                  _selectedType = 'Installation';
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType != null
                      ? Colors.orange
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _selectedType != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FridgeRepairIssueScreen(
                              location: widget.location,
                              serviceType: _selectedType!,
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

class _ServiceTypeOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _ServiceTypeOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Radio(value: true, groupValue: selected, onChanged: (_) => onTap()),
            Text(title),
          ],
        ),
      ),
    );
  }
}
