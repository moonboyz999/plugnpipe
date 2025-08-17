import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';
import '../../services/local_auth_service_demo.dart';
import 'task_request_detail_screen.dart';

class AssignedTasksScreen extends StatefulWidget {
  const AssignedTasksScreen({super.key});

  @override
  State<AssignedTasksScreen> createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends State<AssignedTasksScreen> {
  String selectedFilter = 'Pending Requests';
  final TextEditingController searchController = TextEditingController();
  final LocalSupabaseHelper _localHelper = LocalSupabaseHelper();
  final LocalAuthService _authService = LocalAuthService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('AssignedTasksScreen: initState called'); // Debug
    print('Auth service instance: $_authService'); // Debug
    print('Current user on init: ${_authService.currentUser}'); // Debug
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      print('Current user in assigned tasks: $currentUser'); // Debug
      
      if (currentUser != null) {
        print('Loading requests for user: ${currentUser['userId']}'); // Debug
        
        // Get pending requests that need technician action
        final pendingRequests = await _localHelper.getPendingRequests();
        print('Pending requests loaded: ${pendingRequests.length}'); // Debug
        
        final myTasks = await _localHelper.getTasksForTechnician(currentUser['userId']);
        print('My tasks loaded: ${myTasks.length}'); // Debug
        
        setState(() {
          _requests = [...pendingRequests, ...myTasks];
          _isLoading = false;
        });
      } else {
        print('No current user found, trying to load default technician tasks'); // Debug
        
        // Fallback: Load tasks for a default technician (useful during development)
        final pendingRequests = await _localHelper.getPendingRequests();
        print('Fallback - Pending requests loaded: ${pendingRequests.length}'); // Debug
        
        // Try to get tasks for any technician (for testing purposes)
        final allRequests = await _localHelper.getRequests();
        final techTasks = allRequests.where((request) => 
          request['status'] == 'assigned' || request['status'] == 'in_progress'
        ).toList();
        print('Fallback - Tech tasks loaded: ${techTasks.length}'); // Debug
        
        setState(() {
          _requests = [...pendingRequests, ...techTasks];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e'); // Debug
      setState(() {
        _requests = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredRequests {
    List<Map<String, dynamic>> filtered = _requests;

    // Apply search filter
    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (request) =>
                (request['title'] ?? '').toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                (request['description'] ?? '').toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply status filter
    if (selectedFilter != 'All Requests') {
      String status;
      switch (selectedFilter) {
        case 'Pending Requests':
          status = 'pending';
          break;
        case 'Assigned to Me':
          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            return filtered.where((request) => 
              request['assignedTechnicianId'] == currentUser['userId']).toList();
          }
          return [];
        case 'In Progress':
          status = 'in_progress';
          break;
        case 'Completed':
          status = 'completed';
          break;
        default:
          return filtered;
      }
      filtered = filtered.where((request) => request['status'] == status).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Task Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        Text(
                          '${filteredRequests.length} requests found',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedFilter,
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.grey,
                          ),
                          items:
                              [
                                    'All Requests',
                                    'Pending Requests',
                                    'Assigned to Me',
                                    'In Progress',
                                    'Completed',
                                  ]
                                  .map(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedFilter = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? const Center(
                        child: Text(
                          'No requests found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return RequestCard(
                              request: request,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskRequestDetailScreen(request: request),
                                  ),
                                );
                                // Refresh if the detail screen returned true
                                if (result == true) {
                                  _loadRequests();
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request['title'] ?? 'Service Request',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityChip(request['priority'] ?? 'medium'),
                  const SizedBox(width: 8),
                  _buildStatusChip(request['status'] ?? 'pending'),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                request['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Request Details
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request['location'] ?? 'Unknown location',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    request['category'] ?? 'general',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${_formatDate(request['createdAt'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (request['assignedAt'] != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.assignment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Assigned ${_formatDate(request['assignedAt'])}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String text;
    switch (priority.toLowerCase()) {
      case 'low':
        color = Colors.green;
        text = 'LOW';
        break;
      case 'medium':
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case 'high':
        color = Colors.red;
        text = 'HIGH';
        break;
      case 'urgent':
        color = Colors.purple;
        text = 'URGENT';
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.amber;
        text = 'PENDING';
        break;
      case 'assigned':
        color = Colors.blue;
        text = 'ASSIGNED';
        break;
      case 'in_progress':
        color = Colors.purple;
        text = 'IN PROGRESS';
        break;
      case 'completed':
        color = Colors.green;
        text = 'COMPLETED';
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'CANCELLED';
        break;
      case 'escalated':
        color = Colors.deepOrange;
        text = 'ESCALATED';
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
