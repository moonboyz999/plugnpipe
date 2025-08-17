import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class ElectricalScheduleScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  final List<String> issues;

  const ElectricalScheduleScreen({
    super.key,
    required this.location,
    required this.serviceType,
    required this.issues,
  });

  @override
  State<ElectricalScheduleScreen> createState() =>
      _ElectricalScheduleScreenState();
}

class _ElectricalScheduleScreenState extends State<ElectricalScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  final List<Map<String, String>> _timeSlots = [
    {'time': '09:00 AM - 11:00 AM', 'availability': 'Available'},
    {'time': '11:00 AM - 13:00 PM', 'availability': 'Available'},
    {'time': '13:00 PM - 15:00 PM', 'availability': 'Booked'},
    {'time': '15:00 PM - 17:00 PM', 'availability': 'Available'},
    {'time': '17:00 PM - 19:00 PM', 'availability': 'Available'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule Electrical Service',
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
            // Date selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Time slot selection
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  final isAvailable = slot['availability'] == 'Available';
                  final isSelected = _selectedTimeSlot == slot['time'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ChoiceChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              slot['time']!,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isAvailable
                                          ? Colors.black87
                                          : Colors.grey),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              slot['availability']!,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isAvailable
                                          ? Colors.green[600]
                                          : Colors.red),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: isAvailable
                          ? (selected) {
                              setState(() {
                                _selectedTimeSlot = selected
                                    ? slot['time']
                                    : null;
                              });
                            }
                          : null,
                      selectedColor: const Color(0xFFFFA726),
                      backgroundColor: isAvailable
                          ? Colors.white
                          : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFFFA726)
                              : (isAvailable
                                    ? Colors.grey[300]!
                                    : Colors.grey[400]!),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTimeSlot != null
                      ? const Color(0xFFFFA726)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _selectedTimeSlot != null
                    ? () {
                        _showConfirmationDialog();
                      }
                    : null,
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Confirm Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please confirm your electrical service request:'),
              const SizedBox(height: 12),
              Text('📍 Location: ${widget.location}'),
              Text('⚡ Service: ${widget.serviceType}'),
              Text(
                '📅 Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              Text('⏰ Time: $_selectedTimeSlot'),
              Text('⚠️ Issues: ${widget.issues.join(', ')}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                // Add notification for pending service
                NotificationService().addServiceBooking(
                  serviceType: 'Electrical & Wiring',
                  location: widget.location,
                  date:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  time: _selectedTimeSlot!,
                  issues: widget.issues,
                );

                _showSuccessDialog();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFFFA726), size: 28),
              SizedBox(width: 8),
              Text('Request Submitted!'),
            ],
          ),
          content: const Text(
            'Your electrical service request has been submitted successfully. You will receive a confirmation shortly.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
