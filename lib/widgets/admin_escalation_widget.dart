import 'package:flutter/material.dart';
import '../services/local_supabase_helper.dart';

class AdminEscalationWidget extends StatefulWidget {
  const AdminEscalationWidget({super.key});

  @override
  State<AdminEscalationWidget> createState() => _AdminEscalationWidgetState();
}

class _AdminEscalationWidgetState extends State<AdminEscalationWidget> {
  final LocalSupabaseHelper _helper = LocalSupabaseHelper();
  List<Map<String, dynamic>> _escalatedTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEscalatedTasks();
  }

  Future<void> _loadEscalatedTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _helper.getEscalatedTasks();

      setState(() {
        _escalatedTasks = tasks;
      });
    } catch (e) {
      _showMessage('Error loading escalated tasks: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _urgentAssignTask(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _helper.urgentAssignTask(requestId);
      
      if (success) {
        _showMessage('Task urgently assigned successfully!', isSuccess: true);
        _loadEscalatedTasks(); // Refresh the list
      } else {
        _showMessage('Failed to urgently assign task. No technicians available.', isSuccess: false);
      }
    } catch (e) {
      _showMessage('Error during urgent assignment: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildEscalatedTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Colors.red.shade700,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with warning indicator
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task['title'] ?? 'Service Request',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ESCALATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Task details
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    task['location'] ?? 'Unknown location',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                task['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Escalation time
              if (task['escalatedAt'] != null)
                Text(
                  'Escalated: ${_formatTimestamp(DateTime.parse(task['escalatedAt']))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _urgentAssignTask(task['id']),
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: const Text(
                        'Urgent Assign',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => _showManualAssignDialog(task),
                      icon: Icon(Icons.person_add, color: Colors.grey[700]),
                      label: Text(
                        'Manual Assign',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      style: OutlinedButton.styleFrom(
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
      ),
    );
  }

  void _showManualAssignDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Assignment'),
        content: Text(
          'Manual assignment feature coming soon.\n\n'
          'For now, use "Urgent Assign" to automatically assign to the least busy technician.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700),
              const SizedBox(width: 8),
              const Text(
                'Escalated Tasks - Action Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_escalatedTasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_escalatedTasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Loading indicator
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        
        // Escalated tasks list
        if (_escalatedTasks.isEmpty && !_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No escalated tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All tasks are being handled properly',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (!_isLoading)
          Expanded(
            child: ListView.builder(
              itemCount: _escalatedTasks.length,
              itemBuilder: (context, index) {
                return _buildEscalatedTaskCard(_escalatedTasks[index]);
              },
            ),
          ),
      ],
    );
  }
}
