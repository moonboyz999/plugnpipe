import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../services/local_supabase_helper.dart';
import '../../services/local_auth_service_demo.dart';
import 'task_request_detail_screen.dart';

class EmergencyRequestsScreen extends StatefulWidget {
  const EmergencyRequestsScreen({super.key});

  @override
  State<EmergencyRequestsScreen> createState() =>
      _EmergencyRequestsScreenState();
}

class _EmergencyRequestsScreenState extends State<EmergencyRequestsScreen> {
  final TaskService _taskService = TaskService();
  final LocalSupabaseHelper _db = LocalSupabaseHelper();
  final LocalAuthService _authService = LocalAuthService();
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
      
      // Also get emergency requests
      final emergencyRequests = await _db.select('requests', where: {'priority': 'emergency'});
      
      setState(() {
        _urgentRequests = [...requests, ...emergencyRequests];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading urgent requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to accept requests'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _db.update(
        'requests',
        {
          'status': 'assigned',
          'assignedTechnicianId': currentUser['userId'],
          'acceptedAt': DateTime.now().toIso8601String(),
        },
        id: request['id'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _loadUrgentRequests(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    try {
      await _db.update(
        'requests',
        {
          'status': 'rejected',
          'rejectedAt': DateTime.now().toIso8601String(),
        },
        id: request['id'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected'),
          backgroundColor: Colors.orange,
        ),
      );

      _loadUrgentRequests(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(request['title'] ?? 'Urgent Request'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Location:', request['location'] ?? 'Not specified'),
                _buildDetailRow('Category:', request['category'] ?? 'Not specified'),
                _buildDetailRow('Priority:', request['priority'] ?? 'Not specified'),
                _buildDetailRow('Status:', request['status'] ?? 'Not specified'),
                _buildDetailRow('Description:', request['description'] ?? 'No description'),
                if (request['contactNumber'] != null)
                  _buildDetailRow('Contact:', request['contactNumber']),
                if (request['createdAt'] != null)
                  _buildDetailRow('Created:', _formatDate(request['createdAt'])),
              ],
            ),
          ),
          actions: [
            if (request['status'] == 'pending') ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _rejectRequest(request);
                },
                child: const Text('Reject', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptRequest(request);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept', style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
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
                      leading: Icon(
                        Icons.warning, 
                        color: request['priority'] == 'emergency' ? Colors.red[700] : Colors.red,
                      ),
                      title: Text(request['title'] ?? 'Urgent Request'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request['location'] ?? 'Unknown location'),
                          Text('Status: ${request['status']}'),
                          Text('Category: ${request['category']}'),
                          Text('Priority: ${request['priority']?.toUpperCase() ?? 'URGENT'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (request['status'] == 'pending') ...[
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectRequest(request),
                              tooltip: 'Reject',
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _acceptRequest(request),
                              tooltip: 'Accept',
                            ),
                          ],
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showRequestDetails(request),
                            tooltip: 'View Details',
                          ),
                        ],
                      ),
                      onTap: () => _showRequestDetails(request),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.location),
                                Text('Status: ${task.status}'),
                                Text('Priority: URGENT'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (task.status == TaskStatus.pending) ...[
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      // Handle reject for ServiceTask
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Task rejected'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                    tooltip: 'Reject',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      // Handle accept for ServiceTask
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Task accepted'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    tooltip: 'Accept',
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    // Show task details
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(task.title),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Location: ${task.location}'),
                                            Text('Category: ${task.category}'),
                                            Text('Status: ${task.status}'),
                                            Text('Priority: URGENT'),
                                            if (task.description.isNotEmpty)
                                              Text('Description: ${task.description}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  tooltip: 'View Details',
                                ),
                              ],
                            ),
                            onTap: () {
                              // Show task details
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
