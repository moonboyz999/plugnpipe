import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/notification_service.dart';
import '../../services/local_supabase_helper.dart';
import '../../services/local_auth_service_demo.dart';

class FridgeRepairScheduleScreen extends StatefulWidget {
  final String location;
  final String serviceType;
  final List<String> issues;

  const FridgeRepairScheduleScreen({
    super.key,
    required this.location,
    required this.serviceType,
    required this.issues,
  });

  @override
  State<FridgeRepairScheduleScreen> createState() =>
      _FridgeRepairScheduleScreenState();
}

class _FridgeRepairScheduleScreenState
    extends State<FridgeRepairScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
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
                  'Schedule Fridge Repair',
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
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
                          color: Color(0xFF42A5F5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFFFFD600),
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
                    ? () async {
                        try {
                          // Create the service request using LocalSupabaseHelper
                          final mockHelper = LocalSupabaseHelper();

                          final description =
                              'Fridge repair service requested.\n'
                              'Issues: ${widget.issues.join(", ")}\n'
                              'Preferred Date: ${_selectedDay!.toLocal().toString().split(' ')[0]}\n'
                              'Preferred Time: $_selectedTimeSlot';

                          // Better location parsing
                          String building;
                          String room;
                          
                          print('Original location: ${widget.location}'); // Debug
                          
                          if (widget.location.contains('Kitchen')) {
                            // For kitchen locations, the building is everything before 'Kitchen'
                            building = widget.location.replaceAll(' Kitchen', '');
                            room = 'Kitchen';
                          } else {
                            // For other locations, try to parse building and room
                            final locationParts = widget.location.split(' ');
                            if (locationParts.length >= 2) {
                              building = locationParts.sublist(0, locationParts.length - 1).join(' ');
                              room = locationParts.last;
                            } else {
                              building = widget.location;
                              room = 'General Area';
                            }
                          }
                          
                          print('Parsed building: $building, room: $room'); // Debug

                          // Get current user ID from auth service
                          final authService = LocalAuthService();
                          final currentUser = authService.currentUser;
                          final currentUserId = currentUser?['userId'] ?? 'student_001';

                          await mockHelper.createRequest({
                            'userId': currentUserId,
                            'title': 'Fridge Repair Service',
                            'description': description,
                            'category': 'appliance',
                            'priority': 'medium',
                            'location': widget.location,
                            'building': building,
                            'room': room,
                            'requiresReport': false,
                          });

                          // Also add to notification service for compatibility
                          NotificationService().addServiceBooking(
                            serviceType: 'Fridge Repair',
                            location: widget.location,
                            date:
                                '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            time: _selectedTimeSlot!,
                            issues: widget.issues,
                          );

                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Request Submitted Successfully!',
                                ),
                                content: Text(
                                  'Your fridge repair request has been submitted and notifications have been sent to available technicians.\n\n'
                                  'Location: ${widget.location}\n'
                                  'Service Type: ${widget.serviceType}\n'
                                  'Issues: ${widget.issues.join(", ")}\n'
                                  'Preferred Date: ${_selectedDay!.toLocal().toString().split(' ')[0]}\n'
                                  'Preferred Time: $_selectedTimeSlot\n\n'
                                  'Technicians can now accept or reject your request. You will receive a notification once a technician accepts your task.',
                                ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text('Failed to submit request: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
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
