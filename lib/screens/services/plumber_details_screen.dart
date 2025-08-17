import 'package:flutter/material.dart';
import 'plumber_issues_screen.dart';

class PlumberDetailsScreen extends StatefulWidget {
  const PlumberDetailsScreen({super.key});

  @override
  State<PlumberDetailsScreen> createState() => _PlumberDetailsScreenState();
}

class _PlumberDetailsScreenState extends State<PlumberDetailsScreen> {
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
          'Plumber Details',
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
            // Instructions card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TO MAKE A REQUEST:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. Fill in the details below. Our team will review and confirm your request within 1 hour.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. A plumber will be assigned to conduct a site visit and address your issue.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3. Once repairs begin, you can track updates through the request status.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location selection
            const Text(
              'Where do you need plumbing service?',
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
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Floor',
                  hintText: 'e.g., Floor 5, Level 12, Ground Floor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 12),

              // Room input
              TextField(
                controller: _roomController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Room/Unit',
                  hintText: 'e.g., Room 503, Unit 1205, Block A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Service type selection
            const Text(
              'Type of plumbing service:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _ServiceTypeOption(
              title: 'Urgent Repair',
              description:
                  'Urgent plumbing issues requiring immediate attention',
              selected: _selectedServiceType == 'Urgent Repair',
              onTap: () {
                setState(() {
                  _selectedServiceType = 'Urgent Repair';
                });
              },
            ),
            _ServiceTypeOption(
              title: 'Routine Maintenance',
              description: 'Regular maintenance and inspection services',
              selected: _selectedServiceType == 'Routine Maintenance',
              onTap: () {
                setState(() {
                  _selectedServiceType = 'Routine Maintenance';
                });
              },
            ),
            _ServiceTypeOption(
              title: 'Installation',
              description: 'New fixture installation and setup',
              selected: _selectedServiceType == 'Installation',
              onTap: () {
                setState(() {
                  _selectedServiceType = 'Installation';
                });
              },
            ),

            const SizedBox(height: 32),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_selectedLocation != null &&
                      _selectedServiceType != null &&
                      _floorController.text.isNotEmpty &&
                      _roomController.text.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlumberIssuesScreen(
                          location:
                              '$_selectedLocation - ${_floorController.text}, ${_roomController.text}',
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
