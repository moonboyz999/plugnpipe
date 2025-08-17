import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class UrgentRepairScreen extends StatefulWidget {
  const UrgentRepairScreen({super.key});

  @override
  State<UrgentRepairScreen> createState() => _UrgentRepairScreenState();
}

class _UrgentRepairScreenState extends State<UrgentRepairScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  String? _selectedLocation;

  @override
  void dispose() {
    _problemController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submitUrgentRequest() {
    if (_problemController.text.trim().isEmpty ||
        _selectedLocation == null ||
        _floorController.text.trim().isEmpty ||
        _roomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String fullLocation =
        '$_selectedLocation - Floor ${_floorController.text.trim()}, Room ${_roomController.text.trim()}';

    // Show summary alert
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text('Urgent Request Summary'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your urgent repair request has been submitted:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('Problem:', _problemController.text),
              const SizedBox(height: 8),
              _buildSummaryRow('Location:', fullLocation),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Text(
                  '🚨 Urgent response team will contact you within 15 minutes!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add notification for pending urgent request
                NotificationService().addServiceBooking(
                  serviceType: 'Urgent Repair',
                  location: fullLocation,
                  date: 'Immediate',
                  time: 'ASAP',
                  issues: [_problemController.text.trim()],
                );

                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Urgent Repair',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Urgent Repair Request\nResponse time: 15 minutes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Problem description
            const Text(
              'What is the problem? *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe the urgent repair needed (e.g., water leak, electrical failure, broken door lock)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Location
            const Text(
              'Where is the problem located? *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Location Radio Buttons
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Menara VSQ'),
                    value: 'Menara VSQ',
                    groupValue: _selectedLocation,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                        _floorController.clear();
                        _roomController.clear();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('VSQ'),
                    value: 'VSQ',
                    groupValue: _selectedLocation,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                        _floorController.clear();
                        _roomController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Show floor and room fields only after location selection
            if (_selectedLocation != null) ...[
              const SizedBox(height: 20),

              // Floor field
              TextField(
                controller: _floorController,
                decoration: InputDecoration(
                  labelText: 'Floor *',
                  hintText: 'e.g., Ground Floor, 1st Floor, 5th Floor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Room field
              TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: 'Room/Unit *',
                  hintText: 'e.g., Room 305, Unit A-12, Office 201',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitUrgentRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Submit Urgent Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+60 12-345-6789',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Available 24/7 for emergencies',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
