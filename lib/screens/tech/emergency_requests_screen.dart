import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../services/local_supabase_helper.dart';

class EmergencyRequestsScreen extends StatefulWidget {
  const EmergencyRequestsScreen({super.key});

  @override
  State<EmergencyRequestsScreen> createState() =>
      _EmergencyRequestsScreenState();
}

class _EmergencyRequestsScreenState extends State<EmergencyRequestsScreen> {
  final TaskService _taskService = TaskService();
  final LocalSupabaseHelper _db = LocalSupabaseHelper();
  List<Map<String, dynamic>> _urgentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUrgentRequests();
  }

  Future<void> _loadUrgentRequests() async {
    try {
      // Get urgent requests from database
      final requests = await _db.select('requests', where: {'priority': 'urgent'});
      setState(() {
        _urgentRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading urgent requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Requests'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Urgent Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Database urgent requests
                ..._urgentRequests.map(
                  (request) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(request['title'] ?? 'Urgent Request'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request['location'] ?? 'Unknown location'),
                          Text('Status: ${request['status']}'),
                          Text('Category: ${request['category']}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to request details
                      },
                    ),
                  ),
                ),
                
                // Fallback to TaskService urgent tasks if no database requests
                if (_urgentRequests.isEmpty) ...[
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
                ],
                
                if (_urgentRequests.isEmpty && _taskService.getTasksByPriority(TaskPriority.urgent).isEmpty)
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
