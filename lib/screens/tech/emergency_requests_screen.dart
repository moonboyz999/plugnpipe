import 'package:flutter/material.dart';
import '../../services/task_service.dart';

class EmergencyRequestsScreen extends StatefulWidget {
  const EmergencyRequestsScreen({super.key});

  @override
  State<EmergencyRequestsScreen> createState() =>
      _EmergencyRequestsScreenState();
}

class _EmergencyRequestsScreenState extends State<EmergencyRequestsScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Requests'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Urgent Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._taskService
              .getTasksByPriority(TaskPriority.urgent)
              .map(
                (task) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(task.title),
                    subtitle: Text(task.location),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to task details
                    },
                  ),
                ),
              ),
          if (_taskService.getTasksByPriority(TaskPriority.urgent).isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No emergency requests at the moment',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Alias for UrgentRequestsScreen
class UrgentRequestsScreen extends EmergencyRequestsScreen {
  const UrgentRequestsScreen({super.key});
}
