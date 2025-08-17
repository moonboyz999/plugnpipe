import 'package:flutter/material.dart';
import 'electrical_issues_screen.dart';

class ElectricalDetailsScreen extends StatefulWidget {
  const ElectricalDetailsScreen({super.key});

  @override
  State<ElectricalDetailsScreen> createState() =>
      _ElectricalDetailsScreenState();
}

class _ElectricalDetailsScreenState extends State<ElectricalDetailsScreen> {
  String? _selectedLocation;
  String? _selectedServiceType;
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floorController.addListener(() {
      setState(() {});
    });
    _roomController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _floorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Electrical Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Location & Service Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location selection
            const Text(
              'Where do you need electrical service?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _LocationOption(
              title: 'Menara VSQ',
              selected: _selectedLocation == 'Menara VSQ',
              onTap: () {
                setState(() {
                  _selectedLocation = 'Menara VSQ';
                });
              },
            ),
            _LocationOption(
              title: 'VSQ',
              selected: _selectedLocation == 'VSQ',
              onTap: () {
                setState(() {
                  _selectedLocation = 'VSQ';
                });
              },
            ),

            // Floor and room details text fields (appears when location is selected)
            if (_selectedLocation != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Location Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Floor input
              TextField(
                controller: _floorController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Floor',
                  hintText: 'e.g., 2nd Floor, Ground Floor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Room input
              TextField(
                controller: _roomController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Room Details',
                  hintText: 'e.g., Room 201, Kitchen, Living Room',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.room),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Service type selection
            const Text(
              'Type of electrical service:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _ServiceTypeOption(
              title: 'Urgent Repair',
              description:
                  'Urgent electrical issues requiring immediate attention',
              selected: _selectedServiceType == 'Urgent Repair',
              onTap: () {
                setState(() {
                  _selectedServiceType = 'Urgent Repair';
                });
              },
            ),
            _ServiceTypeOption(
              title: 'Maintenance',
              description: 'Regular maintenance and preventive checks',
              selected: _selectedServiceType == 'Maintenance',
              onTap: () {
                setState(() {
                  _selectedServiceType = 'Maintenance';
                });
              },
            ),

            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_selectedLocation != null &&
                          _selectedServiceType != null &&
                          _floorController.text.isNotEmpty &&
                          _roomController.text.isNotEmpty)
                      ? const Color(0xFFFFA726)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    (_selectedLocation != null &&
                        _selectedServiceType != null &&
                        _floorController.text.isNotEmpty &&
                        _roomController.text.isNotEmpty)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElectricalIssuesScreen(
                              location: _selectedLocation!,
                              serviceType: _selectedServiceType!,
                              floor: _floorController.text,
                              room: _roomController.text,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Continue',
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
  final bool selected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Radio(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFFFFA726),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _ServiceTypeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceTypeOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? const Color(0xFFFFA726) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? const Color(0xFFFFA726).withValues(alpha: 0.1)
                : Colors.white,
          ),
          child: Row(
            children: [
              Radio(
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
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? const Color(0xFFFFA726)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
