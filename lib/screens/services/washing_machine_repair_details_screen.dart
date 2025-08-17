import 'package:flutter/material.dart';
import 'washing_machine_issue_screen.dart';

class WashingMachineRepairDetailsScreen extends StatefulWidget {
  const WashingMachineRepairDetailsScreen({super.key});

  @override
  State<WashingMachineRepairDetailsScreen> createState() =>
      _WashingMachineRepairDetailsScreenState();
}

class _WashingMachineRepairDetailsScreenState
    extends State<WashingMachineRepairDetailsScreen> {
  String? _selectedLocation;
  String? _selectedServiceType;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Service Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Selection Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.orange[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Where is your washing machine located?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LocationOption(
                      title: 'Dormitory Laundry',
                      subtitle: 'Student residential area',
                      selected: _selectedLocation == 'Dormitory Laundry',
                      onTap: () {
                        setState(() {
                          _selectedLocation = 'Dormitory Laundry';
                        });
                      },
                    ),
                    _LocationOption(
                      title: 'Faculty Laundry',
                      subtitle: 'Faculty residential area',
                      selected: _selectedLocation == 'Faculty Laundry',
                      onTap: () {
                        setState(() {
                          _selectedLocation = 'Faculty Laundry';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Type Selection Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.build, color: Colors.orange[600], size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'What type of service do you need?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ServiceTypeOption(
                      title: 'Repair',
                      subtitle: 'Fix existing washing machine issues',
                      selected: _selectedServiceType == 'Repair',
                      onTap: () {
                        setState(() {
                          _selectedServiceType = 'Repair';
                        });
                      },
                    ),
                    _ServiceTypeOption(
                      title: 'Installation',
                      subtitle: 'Install new washing machine or relocate',
                      selected: _selectedServiceType == 'Installation',
                      onTap: () {
                        setState(() {
                          _selectedServiceType = 'Installation';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  if (_selectedLocation != null &&
                      _selectedServiceType != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WashingMachineIssueScreen(
                          location: _selectedLocation!,
                          serviceType: _selectedServiceType!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Continue to Issues',
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

class _LocationOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _LocationOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFA726).withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: selected ? const Color(0xFFFFA726) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: (_) => onTap(),
                activeColor: const Color(0xFFFFA726),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 15,
                        color: selected
                            ? const Color(0xFFFFA726)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _ServiceTypeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFA726).withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: selected ? const Color(0xFFFFA726) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: (_) => onTap(),
                activeColor: const Color(0xFFFFA726),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 15,
                        color: selected
                            ? const Color(0xFFFFA726)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
