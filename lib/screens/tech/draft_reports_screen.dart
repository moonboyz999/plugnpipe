import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'status_report_screen.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'tech_home_screen.dart';
import 'tech_notification_screen.dart';
import 'tech_profile_screen.dart';

class DraftReportsScreen extends StatefulWidget {
  const DraftReportsScreen({super.key});

  @override
  State<DraftReportsScreen> createState() => _DraftReportsScreenState();
}

class _DraftReportsScreenState extends State<DraftReportsScreen> {
  final TaskService _taskService = TaskService();
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final draftsAndCompleted = [
      ..._taskService.getTasksWithDraftReports(),
      ..._taskService.getCompletedTasksNeedingReports(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                        'Draft Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        '${draftsAndCompleted.length} task(s) need attention',
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
      body: draftsAndCompleted.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Draft Reports',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete tasks and create reports to see them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks Requiring Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your status reports for finished tasks',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: draftsAndCompleted.length,
                      itemBuilder: (context, index) {
                        final task = draftsAndCompleted[index];
                        return DraftTaskCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StatusReportScreen(task: task),
                              ),
                            ).then((_) => setState(() {})); // Refresh on return
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: TechNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TechHomeScreen()),
              );
              break;
            case 1:
              // Already on this screen equivalent (draft reports)
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechNotificationScreen(),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

class DraftTaskCard extends StatelessWidget {
  final ServiceTask task;
  final VoidCallback onTap;

  const DraftTaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine draft state via TaskService report cache
    final taskService = TaskService();
    final report = taskService.getReport(task.id);
    final hasDraft = report != null && !report.isSubmitted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasDraft ? Colors.orange[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasDraft ? 'DRAFT SAVED' : 'NEEDS REPORT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: hasDraft ? Colors.orange[800] : Colors.red[800],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    hasDraft ? Icons.edit : Icons.warning,
                    color: hasDraft ? Colors.orange : Colors.red,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    task.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    hasDraft ? 'Continue Editing' : 'Create Report',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFA726),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFFFFA726),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
