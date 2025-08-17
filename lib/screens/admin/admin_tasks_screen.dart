import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';
import '../../widgets/gradient_background.dart';

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({super.key});

  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  final _localHelper = LocalSupabaseHelper();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() => _isLoading = true);

      final requests = await _localHelper.getRequests();

      // Filter based on selected filter
      final filteredRequests = requests.where((request) {
        final status = request['status'] as String? ?? 'pending';
        switch (_selectedFilter) {
          case 'pending':
            return status == 'pending';
          case 'assigned':
            return status == 'assigned';
          case 'in_progress':
            return status == 'in_progress';
          case 'completed':
            return status == 'completed';
          case 'urgent':
            return request['priority'] == 'urgent';
          default:
            return true;
        }
      }).toList();

      if (mounted) {
        setState(() {
          _requests = filteredRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _requests.isEmpty
                  ? _buildEmptyState()
                  : _buildRequestsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All', 'count': _requests.length},
      {
        'key': 'urgent',
        'label': 'Urgent',
        'count': _requests.where((r) => r['priority'] == 'urgent').length,
      },
      {
        'key': 'pending',
        'label': 'Pending',
        'count': _requests.where((r) => r['status'] == 'pending').length,
      },
      {
        'key': 'assigned',
        'label': 'Assigned',
        'count': _requests.where((r) => r['status'] == 'assigned').length,
      },
      {
        'key': 'in_progress',
        'label': 'In Progress',
        'count': _requests.where((r) => r['status'] == 'in_progress').length,
      },
      {
        'key': 'completed',
        'label': 'Completed',
        'count': _requests.where((r) => r['status'] == 'completed').length,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${filter['label']} (${filter['count']})',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter['key'] as String;
                  });
                  _loadRequests();
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF1976D2),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            'No requests found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Requests will appear here when submitted',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final priority = request['priority'] as String;
    final student = request['student'] as Map<String, dynamic>?;
    final assignedTechnician =
        request['assigned_technician'] as Map<String, dynamic>?;
    final createdAt = DateTime.parse(request['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPriorityBadge(priority),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              request['title'] ?? 'Untitled Request',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              request['description'] ?? 'No description',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            if (student != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Student: ${student['username'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request['location'] ?? 'No location',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  (request['category'] as String?)?.toUpperCase() ??
                      'NO CATEGORY',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            if (assignedTechnician != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.engineering, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Technician: ${assignedTechnician['username'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildActionButtons(request),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final requestId = request['id'] as String;

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAssignTechnicianDialog(requestId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Assign Technician',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRequestDetails(request),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1976D2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(color: Color(0xFF1976D2)),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showRequestDetails(request),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1976D2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View Details',
            style: TextStyle(color: Color(0xFF1976D2)),
          ),
        ),
      );
    }
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.grey;
        break;
      case 'assigned':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showAssignTechnicianDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Technician'),
        content: const Text('Auto-assign a technician to this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _localHelper.assignTask(requestId, 'tech_001');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Technician assigned successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadRequests();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error assigning technician: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Auto-Assign'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request['title'] ?? 'Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Description: ${request['description'] ?? 'No description'}',
              ),
              const SizedBox(height: 8),
              Text('Location: ${request['location'] ?? 'No location'}'),
              const SizedBox(height: 8),
              Text('Category: ${request['category'] ?? 'No category'}'),
              const SizedBox(height: 8),
              Text('Priority: ${request['priority'] ?? 'No priority'}'),
              const SizedBox(height: 8),
              Text('Status: ${request['status'] ?? 'No status'}'),
              if (request['contact_info'] != null) ...[
                const SizedBox(height: 8),
                Text('Contact: ${request['contact_info']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
