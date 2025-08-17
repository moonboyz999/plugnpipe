import 'package:flutter/material.dart';
import 'completed_task_detail_screen.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../../services/task_service.dart';
import 'tech_home_screen.dart';
import 'tech_notification_screen.dart';
import 'tech_profile_screen.dart';

class WorkHistoryScreen extends StatefulWidget {
  const WorkHistoryScreen({super.key});

  @override
  State<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends State<WorkHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final int _currentNavIndex = 0; // For navigation bar
  final TaskService _taskService = TaskService();

  // Get completed tasks with submitted reports from TaskService
  List<ServiceTask> get completedTasks => _taskService.getCompletedTasksWithSubmittedReports();
  List<ServiceTask> get filteredTasks {
    List<ServiceTask> filtered = completedTasks;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                task.location.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply priority filter
    if (_selectedFilter != 'All') {
      TaskPriority priority;
      switch (_selectedFilter) {
        case 'High Priority':
          priority = TaskPriority.high;
          break;
        case 'Medium Priority':
          priority = TaskPriority.medium;
          break;
        case 'Low Priority':
          priority = TaskPriority.low;
          break;
        default:
          return filtered;
      }
      filtered = filtered.where((task) => task.priority == priority).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Work History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'Completed tasks and reports',
                        style: TextStyle(fontSize: 14, color: Colors.brown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search completed tasks...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFFFA726),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Dropdown
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Color(0xFFFFA726)),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            [
                                  'All',
                                  'High Priority',
                                  'Medium Priority',
                                  'Low Priority',
                                ]
                                .map(
                                  (filter) => DropdownMenuItem(
                                    value: filter,
                                    child: Text(filter),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No completed tasks found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Completed tasks will appear here',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: TechNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          _handleNavigation(context, index);
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TechHomeScreen()),
        );
        break;
      case 1: // Notifications
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TechNotificationScreen(),
          ),
        );
        break;
      case 2: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TechProfileScreen()),
        );
        break;
    }
  }

  Widget _buildTaskCard(ServiceTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompletedTaskDetailScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildPriorityChip(task.priority),
                ],
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
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFFFFA726),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green,
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
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFFFFA726),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${task.actualCompletion?.toString().split(' ')[0] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Color(0xFFFFA726),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'View Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.w600,
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

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;
    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        text = 'LOW';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case TaskPriority.high:
        color = Colors.red;
        text = 'HIGH';
        break;
      case TaskPriority.urgent:
        color = Colors.red.shade700;
        text = 'URGENT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
