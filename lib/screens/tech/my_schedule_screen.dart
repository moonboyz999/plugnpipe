import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'task_detail_screen.dart';
import '../../services/schedule_service.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'tech_home_screen.dart';
import 'tech_notification_screen.dart';
import 'tech_profile_screen.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final int _currentNavIndex = 0; // For navigation bar

  // Demo accepted tasks that appear in schedule - these will be replaced by service data
  List<ScheduledTask> get scheduledTasks {
    final serviceTasks = _scheduleService.scheduledTasks;
    if (serviceTasks.isNotEmpty) {
      return serviceTasks;
    }

    // Demo data for initial display
    return [
      ScheduledTask(
        task: ServiceTask(
          id: 'TSK001',
          title: 'Fridge Repair - Dormitory Kitchen',
          description: 'Gas Refill required. Issues: Door seal problems.',
          location: 'Dormitory Kitchen',
          category: TaskCategory.general,
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          createdAt: DateTime.parse('2025-08-09'),
        ),
        scheduledTime: '09:00',
        status: ScheduleStatus.completed,
      ),
      ScheduledTask(
        task: ServiceTask(
          id: 'TSK002',
          title: 'Fridge Repair - Dormitory Kitchen',
          description: 'Gas Refill required. Issues: Door seal problems.',
          location: 'Dormitory Kitchen',
          category: TaskCategory.general,
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          createdAt: DateTime.parse('2025-08-10'),
        ),
        scheduledTime: '09:00',
        status: ScheduleStatus.completed,
      ),
    ];
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
                    children: [
                      const Text(
                        'My Schedule',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'Today\'s schedule - ${_getCurrentDate()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Text(
              'Today - ${_getCurrentDate()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // Schedule List
          Expanded(
            child: scheduledTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks scheduled for today',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Accepted tasks will appear here',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scheduledTasks.length,
                    itemBuilder: (context, index) {
                      final scheduledTask = scheduledTasks[index];
                      return _buildScheduleCard(scheduledTask);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: TechNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          _handleNavigation(context, index);
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TechHomeScreen()),
        );
        break;
      case 1: // Notifications
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TechNotificationScreen(),
          ),
        );
        break;
      case 2: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TechProfileScreen()),
        );
        break;
    }
  }

  Widget _buildScheduleCard(ScheduledTask scheduledTask) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: scheduledTask.task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time Section
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFA726)),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFFFFA726),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scheduledTask.scheduledTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheduledTask.task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA726).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFFA726)),
                          ),
                          child: const Text(
                            'TASK',
                            style: TextStyle(
                              color: Color(0xFFFFA726),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scheduledTask.task.estimatedCompletion
                                  ?.toString()
                                  .split(' ')[1] ??
                              '2-3 hours',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scheduledTask.task.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleStatusChip(scheduledTask.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleStatusChip(ScheduleStatus status) {
    Color color;
    String text;
    switch (status) {
      case ScheduleStatus.scheduled:
        color = Colors.blue;
        text = 'SCHEDULED';
        break;
      case ScheduleStatus.inProgress:
        color = Colors.orange;
        text = 'IN PROGRESS';
        break;
      case ScheduleStatus.completed:
        color = Colors.green;
        text = 'COMPLETED';
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

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.month}/${now.day}/${now.year}';
  }
}

class ScheduledTask {
  final ServiceTask task;
  final String scheduledTime;
  final ScheduleStatus status;

  ScheduledTask({
    required this.task,
    required this.scheduledTime,
    required this.status,
  });
}

enum ScheduleStatus { scheduled, inProgress, completed }
