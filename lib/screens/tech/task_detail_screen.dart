import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'status_report_screen.dart';
import 'my_schedule_screen.dart';
import '../../services/schedule_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final ServiceTask task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskStatus currentStatus;
  final ScheduleService _scheduleService = ScheduleService();
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    currentStatus = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.brown),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'View and manage task',
                        style: TextStyle(fontSize: 14, color: Colors.brown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Task Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Priority and Status Badges
                  Row(
                    children: [
                      _buildPriorityChip(widget.task.priority),
                      const SizedBox(width: 8),
                      _buildStatusChip(currentStatus),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.task.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Task Information Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    widget.task.location,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time,
                    'Estimated Time',
                    widget.task.estimatedCompletion?.toString().split(' ')[1] ??
                        'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Created',
                    widget.task.createdAt.toString().split(' ')[0],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on,
                    'Building',
                    widget.task.building ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.person,
                    'Technician ID',
                    widget.task.assignedTechnicianId ?? 'Unassigned',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActionButtons(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (currentStatus) {
      case TaskStatus.pending:
        return Row(
          children: [
            // Accept Task Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showAcceptDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Accept Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Reject Task Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showRejectDialog();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Reject Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case TaskStatus.inProgress:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showMarkDoneDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Mark Work as Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case TaskStatus.completed:
        return Column(
          children: [
            // Report Required Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Report Required to Complete Task',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Physical work is done! Please complete and submit your status report to officially finish this task and move it to work history.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Complete Status Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showCompleteReportDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Complete Status Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case TaskStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'This task has been cancelled',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;
    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        text = 'LOW PRIORITY';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = 'MEDIUM PRIORITY';
        break;
      case TaskPriority.high:
        color = Colors.red;
        text = 'HIGH PRIORITY';
        break;
      case TaskPriority.urgent:
        color = Colors.red.shade700;
        text = 'URGENT PRIORITY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String text;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.amber;
        text = 'PENDING';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = 'IN PROGRESS';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = 'COMPLETED';
        break;
      case TaskStatus.cancelled:
        color = Colors.grey;
        text = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFFA726)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Task'),
        content: const Text('Are you sure you want to accept this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptTask();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Task'),
        content: const Text('Are you sure you want to reject this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectTask();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _acceptTask() {
    setState(() {
      currentStatus = TaskStatus.inProgress;
    });

    // Update task service to mark as accepted
    _taskService.markTaskAsAccepted(widget.task.id);

    // Add task to schedule with current time
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _scheduleService.addTaskToSchedule(widget.task, currentTime);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task accepted successfully! Added to your schedule.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task rejected successfully!'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }

  void _showMarkDoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Work as Done'),
          content: const Text(
            'Are you sure you want to mark this task as completed?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentStatus = TaskStatus.completed;
                });

                // Update schedule status to completed
                _scheduleService.updateTaskStatus(
                  widget.task.id,
                  ScheduleStatus.completed,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task marked as completed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Done'),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteReportDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusReportScreen(task: widget.task),
      ),
    );
  }
}
