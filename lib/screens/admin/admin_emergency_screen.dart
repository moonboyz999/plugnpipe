import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';

class AdminEmergencyScreen extends StatefulWidget {
  const AdminEmergencyScreen({super.key});

  @override
  State<AdminEmergencyScreen> createState() => _AdminEmergencyScreenState();
}

class _AdminEmergencyScreenState extends State<AdminEmergencyScreen> {
  final LocalSupabaseHelper _dbHelper = LocalSupabaseHelper();
  List<Map<String, dynamic>> _emergencyTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyTasks();
  }

  Future<void> _loadEmergencyTasks() async {
    try {
      setState(() => _isLoading = true);
      
      // Get all requests and filter for urgent/emergency ones
      final allRequests = await _dbHelper.getRequests();
      final emergencyRequests = allRequests.where((request) => 
        request['priority'] == 'urgent' || 
        request['service_type']?.toString().toLowerCase().contains('emergency') == true
      ).toList();

      // Sort by creation date (newest first)
      emergencyRequests.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _emergencyTasks = emergencyRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading emergency tasks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    final date = DateTime.tryParse(dateString);
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'PENDING ASSIGNMENT';
      case 'assigned':
        return 'ASSIGNED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'rejected':
        return 'REJECTED';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _emergencyTasks.where((task) => task['status'] == 'pending').length;
    final inProgressCount = _emergencyTasks.where((task) => task['status'] == 'in_progress').length;
    final completedCount = _emergencyTasks.where((task) => task['status'] == 'completed').length;

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
                    Icons.emergency,
                    size: 32,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Emergency Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadEmergencyTasks,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            
            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      pendingCount.toString(),
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'In Progress',
                      inProgressCount.toString(),
                      Colors.blue,
                      Icons.build,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      completedCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Emergency Tasks List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _emergencyTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                size: 64,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No emergency tasks!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All emergency situations are resolved.',
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
                          itemCount: _emergencyTasks.length,
                          itemBuilder: (context, index) {
                            final task = _emergencyTasks[index];
                            return _buildEmergencyTaskCard(task);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTaskCard(Map<String, dynamic> task) {
    final String title = task['service_type'] ?? 'Unknown Service';
    final String description = task['description'] ?? 'No description';
    final String location = task['location'] ?? 'Unknown Location';
    final String status = task['status'] ?? 'pending';
    final String studentName = task['student_name'] ?? 'Unknown Student';
    final String technician = task['assigned_technician'] ?? 'Unassigned';
    final String timeAgo = _getTimeAgo(task['created_at']);
    final Color statusColor = _getStatusColor(status);
    final String statusText = _getStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
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
                Icon(
                  Icons.emergency,
                  size: 20,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 8),
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Details Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              studentName,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              technician,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Priority Banner
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'URGENT PRIORITY - Requires immediate attention',
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
      ),
    );
  }
}
