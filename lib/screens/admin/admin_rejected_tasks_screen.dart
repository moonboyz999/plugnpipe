import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';
import '../../services/auto_assignment_service.dart';

class AdminRejectedTasksScreen extends StatefulWidget {
  const AdminRejectedTasksScreen({super.key});

  @override
  State<AdminRejectedTasksScreen> createState() => _AdminRejectedTasksScreenState();
}

class _AdminRejectedTasksScreenState extends State<AdminRejectedTasksScreen> {
  final LocalSupabaseHelper _dbHelper = LocalSupabaseHelper();
  final AutoAssignmentService _assignmentService = AutoAssignmentService();
  List<Map<String, dynamic>> _rejectedTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRejectedTasks();
  }

  Future<void> _loadRejectedTasks() async {
    try {
      setState(() => _isLoading = true);
      
      // Get all requests and filter for rejected ones
      final allRequests = await _dbHelper.getRequests();
      final rejectedRequests = allRequests.where((request) => 
        request['status'] == 'rejected' && 
        request['priority'] != 'urgent'
      ).toList();

      if (mounted) {
        setState(() {
          _rejectedTasks = rejectedRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading rejected tasks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _escalateToUrgent(String taskId) async {
    try {
      // Update task priority to urgent
      await _dbHelper.updateRequest(taskId, {'priority': 'urgent', 'status': 'pending'});
      
      // Trigger urgent assignment workflow
      await _assignmentService.handleUrgentRequest(taskId);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task escalated to urgent priority successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Refresh the list
        _loadRejectedTasks();
      }
    } catch (e) {
      print('Error escalating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error escalating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reassignTask(String taskId) async {
    try {
      // Reset status to pending for reassignment
      await _dbHelper.updateRequest(taskId, {'status': 'pending'});
      
      // Trigger assignment process
      await _assignmentService.assignTask(taskId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task reassigned successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
        
        // Refresh the list
        _loadRejectedTasks();
      }
    } catch (e) {
      print('Error reassigning task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reassigning task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.cancel,
                    size: 32,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Rejected Tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadRejectedTasks,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            
            // Stats Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_rejectedTasks.length} tasks require admin attention',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tasks List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rejectedTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No rejected tasks!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All tasks are being handled smoothly.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _rejectedTasks.length,
                          itemBuilder: (context, index) {
                            final task = _rejectedTasks[index];
                            return _buildRejectedTaskCard(task);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedTaskCard(Map<String, dynamic> task) {
    final String title = task['service_type'] ?? 'Unknown Service';
    final String description = task['description'] ?? 'No description';
    final String location = task['location'] ?? 'Unknown Location';
    final String studentName = task['student_name'] ?? 'Unknown Student';
    final String rejectionReason = task['rejection_reason'] ?? 'No reason provided';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'REJECTED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Task Details
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Location and Student
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  studentName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Rejection Reason
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rejection Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rejectionReason,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _escalateToUrgent(task['id']),
                    icon: const Icon(Icons.priority_high, size: 18),
                    label: const Text('Escalate to Urgent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reassignTask(task['id']),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reassign'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
