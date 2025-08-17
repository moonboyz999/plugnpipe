import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/notification_service.dart';

class WashingMachineScheduleScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  final List<String> issues;
  const WashingMachineScheduleScreen({
    super.key,
    required this.location,
    required this.serviceType,
    required this.issues,
  });

  @override
  State<WashingMachineScheduleScreen> createState() =>
      _WashingMachineScheduleScreenState();
}

class _WashingMachineScheduleScreenState
    extends State<WashingMachineScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  final List<Map<String, String>> _timeSlots = [
    {'time': '09:00 AM - 11:00 AM', 'availability': 'Available'},
    {'time': '11:00 AM - 01:00 PM', 'availability': 'Available'},
    {'time': '01:00 PM - 03:00 PM', 'availability': 'Unavailable'},
    {'time': '03:00 PM - 05:00 PM', 'availability': 'Available'},
    {'time': '05:00 PM - 07:00 PM', 'availability': 'Available'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Washing Machine Repair'),
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return _selectedDay != null &&
                            day.year == _selectedDay!.year &&
                            day.month == _selectedDay!.month &&
                            day.day == _selectedDay!.day;
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color(0xFFFFA726),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFFFF8F00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Time Slot',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Time slot selection
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_selectedDay != null && _selectedTimeSlot != null)
                      ? const Color(0xFFFFA726)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (_selectedDay != null && _selectedTimeSlot != null)
                    ? () {
                        // Add notification for pending service
                        NotificationService().addServiceBooking(
                          serviceType: 'Washing Machine Repair',
                          location: widget.location,
                          date:
                              '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          time: _selectedTimeSlot!,
                          issues: widget.issues,
                        );

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Schedule Confirmed'),
                            content: Text(
                              'Location: ${widget.location}\n'
                              'Service Type: ${widget.serviceType}\n'
                              'Issues: ${widget.issues.join(", ")}\n'
                              'Date: ${_selectedDay!.toLocal().toString().split(' ')[0]}\n'
                              'Time: $_selectedTimeSlot',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                child: const Text('Continue to Summary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
