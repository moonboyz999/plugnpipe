import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';

class TechnicianWorkloadWidget extends StatefulWidget {
  const TechnicianWorkloadWidget({super.key});

  @override
  State<TechnicianWorkloadWidget> createState() => _TechnicianWorkloadWidgetState();
}

class _TechnicianWorkloadWidgetState extends State<TechnicianWorkloadWidget> {
  final LocalSupabaseHelper _helper = LocalSupabaseHelper();
  Map<String, dynamic> _workloadStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkloadStats();
  }

  Future<void> _loadWorkloadStats() async {
    try {
      final stats = await _helper.getTechnicianWorkloadStats();
      setState(() {
        _workloadStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_workloadStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No technicians found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.engineering, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Technician Workload',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadWorkloadStats,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._workloadStats.entries.map((entry) {
              final techId = entry.key;
              final stats = entry.value as Map<String, dynamic>;
              return _buildTechnicianRow(techId, stats);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianRow(String techId, Map<String, dynamic> stats) {
    final name = stats['name'] as String;
    final assigned = stats['assigned'] as int;
    final inProgress = stats['inProgress'] as int;
    final completed = stats['completed'] as int;
    final total = stats['total'] as int;

    Color workloadColor;
    if (total == 0) {
      workloadColor = Colors.green;
    } else if (total <= 2) {
      workloadColor = Colors.orange;
    } else {
      workloadColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: workloadColor.withValues(alpha: 0.1),
            child: Text(
              name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').join(''),
              style: TextStyle(
                color: workloadColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip('Assigned', assigned, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('In Progress', inProgress, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatChip('Completed', completed, Colors.green),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: workloadColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: workloadColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Total: $total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: workloadColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
