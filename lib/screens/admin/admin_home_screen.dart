import 'package:flutter/material.dart';
import '../../widgets/admin_escalation_widget.dart';
import '../../debug_database.dart';
import '../../services/local_supabase_helper.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final LocalSupabaseHelper _dbHelper = LocalSupabaseHelper();
  Map<String, int> _stats = {};
  bool _isLoading = true;
  
  // Task tab management
  int _selectedTaskTab = 0;
  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _pendingTasks = [];
  List<Map<String, dynamic>> _rejectedTasks = [];
  List<Map<String, dynamic>> _emergencyTasks = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      
      final requests = await _dbHelper.getRequests();
      final users = await _dbHelper.getUsers();
      
      final pendingRequests = requests.where((r) => r['status'] == 'pending').length;
      final rejectedRequests = requests.where((r) => r['status'] == 'rejected').length;
      final urgentRequests = requests.where((r) => r['priority'] == 'urgent').length;
      final completedTasks = requests.where((r) => r['status'] == 'completed').length;
      final technicians = users.where((u) => u['role'] == 'technician').length;
      final students = users.where((u) => u['role'] == 'student').length;
      
      // Categorize tasks for the task management section
      _allTasks = requests;
      _pendingTasks = requests.where((r) => r['status'] == 'pending').toList();
      _rejectedTasks = requests.where((r) => r['status'] == 'rejected').toList();
      _emergencyTasks = requests.where((r) => 
        r['priority'] == 'urgent' || 
        r['service_type']?.toString().toLowerCase().contains('emergency') == true
      ).toList();
      
      if (mounted) {
        setState(() {
          _stats = {
            'pending': pendingRequests,
            'rejected': rejectedRequests,
            'urgent': urgentRequests,
            'completed': completedTasks,
            'technicians': technicians,
            'students': students,
            'total_requests': requests.length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
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
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      icon: Icons.pending_actions,
                      title: 'Pending Tasks',
                      value: '${_stats['pending'] ?? 0}',
                      subtitle: 'Awaiting assignment',
                      color: Colors.orange,
                      backgroundColor: Colors.orange[50]!,
                    ),
                    _buildStatCard(
                      icon: Icons.cancel,
                      title: 'Rejected Tasks',
                      value: '${_stats['rejected'] ?? 0}',
                      subtitle: 'Need admin action',
                      color: Colors.red,
                      backgroundColor: Colors.red[50]!,
                    ),
                    _buildStatCard(
                      icon: Icons.emergency,
                      title: 'Urgent Tasks',
                      value: '${_stats['urgent'] ?? 0}',
                      subtitle: 'High priority',
                      color: Colors.purple,
                      backgroundColor: Colors.purple[50]!,
                    ),
                    _buildStatCard(
                      icon: Icons.engineering,
                      title: 'Technicians',
                      value: '${_stats['technicians'] ?? 0}',
                      subtitle: 'Active accounts',
                      color: Colors.green,
                      backgroundColor: Colors.green[50]!,
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
                'Task Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Task Status Tabs
              _buildTaskStatusTabs(),

              const SizedBox(height: 20),
              
              // Debug Button (Development Only)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Database Debug')),
                          body: DatabaseDebugWidget(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug Database'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStatusTabs() {
    final tabTitles = ['All Tasks', 'Pending', 'Rejected', 'Emergency'];
    final taskCounts = [
      _allTasks.length,
      _pendingTasks.length,
      _rejectedTasks.length,
      _emergencyTasks.length,
    ];

    return Column(
      children: [
        // Tab Headers
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: List.generate(4, (index) {
              final isSelected = _selectedTaskTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTaskTab = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFA726) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '(${taskCounts[index]})',
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tab Content
        _buildTaskTabContent(),
      ],
    );
  }

  Widget _buildTaskTabContent() {
    List<Map<String, dynamic>> currentTasks;
    switch (_selectedTaskTab) {
      case 0:
        currentTasks = _allTasks;
        break;
      case 1:
        currentTasks = _pendingTasks;
        break;
      case 2:
        currentTasks = _rejectedTasks;
        break;
      case 3:
        currentTasks = _emergencyTasks;
        break;
      default:
        currentTasks = _allTasks;
    }

    if (currentTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: currentTasks.take(5).map((task) => _buildTaskCard(task)).toList(),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String title = task['title'] ?? 'Untitled Task';
    final String status = task['status'] ?? 'pending';
    final String priority = task['priority'] ?? 'medium';
    final String category = task['category'] ?? 'general';
    final String location = task['location'] ?? 'Unknown';
    final bool isUrgent = priority == 'urgent';
    
    Color statusColor;
    Color priorityColor;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'assigned':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    switch (priority) {
      case 'urgent':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'medium':
        priorityColor = Colors.yellow[700]!;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    border: Border.all(color: priorityColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (status == 'rejected')
                  ElevatedButton(
                    onPressed: () => _escalateTask(task['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Escalate', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _escalateTask(String taskId) async {
    try {
      // Update task priority to urgent
      await _dbHelper.updateRequest(taskId, {'priority': 'urgent'});
      
      // Reload data to reflect changes
      await _loadDashboardData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task escalated to urgent priority'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error escalating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to escalate task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
