import 'package:flutter/material.dart';
import 'washing_machine_issue_screen.dart';

class WashingMachineServiceTypeScreen extends StatefulWidget {
  final String location;
  const WashingMachineServiceTypeScreen({super.key, required this.location});

  @override
  State<WashingMachineServiceTypeScreen> createState() =>
      _WashingMachineServiceTypeScreenState();
}

class _WashingMachineServiceTypeScreenState
    extends State<WashingMachineServiceTypeScreen> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: const [
                SizedBox(width: 16),
                Text(
                  'Washing Machine Repair Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What type of service do you need?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
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
                      ? Colors.blue
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
                            builder: (context) => WashingMachineIssueScreen(
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
