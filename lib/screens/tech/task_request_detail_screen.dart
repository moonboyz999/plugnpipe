import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';
import '../../services/local_auth_service_demo.dart';

class TaskRequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const TaskRequestDetailScreen({
    super.key,
    required this.request,
  });

  @override
  State<TaskRequestDetailScreen> createState() => _TaskRequestDetailScreenState();
}

class _TaskRequestDetailScreenState extends State<TaskRequestDetailScreen> {
  final LocalSupabaseHelper _localHelper = LocalSupabaseHelper();
  final LocalAuthService _authService = LocalAuthService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    print('TaskRequestDetailScreen - request data: $request'); // Debug
    
    final isAssigned = request['assignedTechnicianId'] != null;
    final currentUser = _authService.currentUser;
    final isAssignedToMe = request['assignedTechnicianId'] == currentUser?['userId'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with gradient
          Container(
            height: 120,
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
                    const Expanded(
                      child: Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _getStatusColor(request['status'] ?? 'pending').withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(request['status'] ?? 'pending'),
                            color: _getStatusColor(request['status'] ?? 'pending'),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getStatusText(request['status'] ?? 'pending'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(request['status'] ?? 'pending'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Request Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['title'] ?? 'Service Request',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow('Description', request['description'] ?? 'No description'),
                          const Divider(),
                          _buildDetailRow('Location', request['location'] ?? 'Unknown'),
                          const Divider(),
                          _buildDetailRow('Building', request['building'] ?? 'N/A'),
                          const Divider(),
                          _buildDetailRow('Room', request['room'] ?? 'N/A'),
                          const Divider(),
                          _buildDetailRow('Category', request['category'] ?? 'general'),
                          const Divider(),
                          _buildDetailRow('Priority', request['priority'] ?? 'medium'),
                          const Divider(),
                          _buildDetailRow('Created', _formatDate(request['createdAt'])),
                          
                          if (request['assignedAt'] != null) ...[
                            const Divider(),
                            _buildDetailRow('Assigned', _formatDate(request['assignedAt'])),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  if (request['status'] == 'pending' && !isAssigned && currentUser != null) ...[
                    // Accept/Decline buttons for pending requests
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => _acceptRequest(),
                            icon: _isProcessing 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle),
                            label: Text(_isProcessing ? 'Processing...' : 'Accept Task'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => _rejectRequest(),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Decline'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isAssignedToMe) ...[
                    // Start work button for assigned tasks
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _startWork(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Work'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() => _isProcessing = true);

    try {
      await _localHelper.acceptTask(widget.request['id'], currentUser['userId']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectRequest() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() => _isProcessing = true);

    try {
      await _localHelper.rejectTask(widget.request['id'], currentUser['userId']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task declined'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _startWork() {
    // TODO: Implement start work functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work started! This feature will be implemented soon.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'escalated':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'assigned':
        return Icons.assignment;
      case 'in_progress':
        return Icons.build_circle;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'escalated':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Assignment';
      case 'assigned':
        return 'Assigned to You';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'escalated':
        return 'Escalated';
      default:
        return 'Unknown Status';
    }
  }
}
