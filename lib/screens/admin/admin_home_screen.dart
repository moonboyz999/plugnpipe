import 'package:flutter/material.dart';
import '../../widgets/admin_escalation_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: Color(0xFFFFA726),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    icon: Icons.description,
                    title: 'Reports',
                    value: '2',
                    subtitle: 'Submitted today',
                    color: Colors.blue,
                    backgroundColor: Colors.blue[50]!,
                  ),
                  _buildStatCard(
                    icon: Icons.engineering,
                    title: 'Technicians',
                    value: '0',
                    subtitle: 'Active accounts',
                    color: Colors.green,
                    backgroundColor: Colors.green[50]!,
                  ),
                  _buildStatCard(
                    icon: Icons.build,
                    title: 'Service Requests',
                    value: '12',
                    subtitle: 'Total requests',
                    color: Colors.purple,
                    backgroundColor: Colors.purple[50]!,
                  ),
                  _buildStatCard(
                    icon: Icons.trending_up,
                    title: 'System Status',
                    value: '99.9%',
                    subtitle: 'Uptime',
                    color: Colors.cyan,
                    backgroundColor: Colors.cyan[50]!,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Escalated Tasks Section - PRIORITY
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const AdminEscalationWidget(),
              ),

              const SizedBox(height: 32),

              // Task Status Section
              const Text(
                'Task Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Pending Tasks List
              ...(_getPendingTasks().map(
                (task) => _buildPendingTaskCard(task),
              )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Get list of pending tasks (mock data for demonstration)
  List<Map<String, dynamic>> _getPendingTasks() {
    return [
      {
        'id': 'TSK001',
        'title': 'Electrical Repair - Room 201',
        'assignedTo': 'John Doe',
        'daysPending': 3,
        'priority': 'High',
        'description': 'Faulty electrical outlet in student dormitory',
        'isEmergency': false,
      },
      {
        'id': 'TSK002',
        'title': 'Plumbing Issue - Cafeteria',
        'assignedTo': 'Jane Smith',
        'daysPending': 5,
        'priority': 'Medium',
        'description': 'Leaking pipe under sink needs immediate attention',
        'isEmergency': false,
      },
      {
        'id': 'TSK003',
        'title': 'AC Repair - Library',
        'assignedTo': 'Mike Johnson',
        'daysPending': 7,
        'priority': 'High',
        'description': 'Air conditioning unit not working properly',
        'isEmergency': false,
      },
    ];
  }

  Widget _buildPendingTaskCard(Map<String, dynamic> task) {
    final int daysPending = task['daysPending'];
    final bool isOverdue = daysPending >= 3;
    final bool isEmergency = task['isEmergency'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isOverdue
            ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1)
            : null,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${task['assignedTo']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? Colors.red.withValues(alpha: 0.1)
                      : isOverdue
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEmergency ? 'EMERGENCY' : '$daysPending days pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEmergency
                        ? Colors.red[700]
                        : isOverdue
                        ? Colors.orange[700]
                        : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task['description'],
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task['priority'] == 'High'
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${task['priority']} Priority',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: task['priority'] == 'High'
                        ? Colors.red[700]
                        : Colors.grey[700],
                  ),
                ),
              ),
              const Spacer(),
              if (!isEmergency && isOverdue)
                ElevatedButton.icon(
                  onPressed: () => _markAsEmergency(task['id']),
                  icon: const Icon(Icons.warning, size: 16),
                  label: const Text('Mark Emergency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (!isEmergency && !isOverdue)
                OutlinedButton(
                  onPressed: () => _viewTaskDetails(task['id']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View Details'),
                ),
              if (isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emergency, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Emergency Task',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _markAsEmergency(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Emergency'),
          content: Text(
            'Are you sure you want to mark task $taskId as an emergency? This will notify all available technicians immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEmergencyNotification(taskId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Emergency'),
            ),
          ],
        );
      },
    );
  }

  void _viewTaskDetails(String taskId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening task details for $taskId'),
        backgroundColor: const Color(0xFFFFA726),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmergencyNotification(String taskId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task $taskId marked as emergency! All technicians notified.',
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Refresh the UI to show updated task status
    setState(() {});
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
