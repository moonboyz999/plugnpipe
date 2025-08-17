import 'package:flutter/material.dart';
import '../../services/task_service.dart';

class CompletedTaskDetailScreen extends StatelessWidget {
  final ServiceTask task;

  const CompletedTaskDetailScreen({super.key, required this.task});

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
                        'Task Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'Completed task details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildPriorityChip(task.priority),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Task Information
            _buildSectionTitle('Task Information'),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow(Icons.location_on, 'Location', task.location),
              _buildInfoRow(
                Icons.access_time,
                'Estimated Time',
                task.estimatedCompletion?.toString().split(' ')[1] ?? 'N/A',
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'Assigned Date',
                task.createdAt.toString().split(' ')[0],
              ),
              _buildInfoRow(
                Icons.event,
                'Completion Date',
                task.actualCompletion?.toString().split(' ')[0] ?? 'N/A',
              ),
              _buildInfoRow(
                Icons.person,
                'Technician ID',
                task.assignedTechnicianId ?? 'Unassigned',
              ),
            ]),
            const SizedBox(height: 24),

            // Status Report
            _buildSectionTitle('Status Report'),
            const SizedBox(height: 16),
            _buildStatusReportCard(),
            const SizedBox(height: 24),

            // Work Details
            _buildSectionTitle('Work Details'),
            const SizedBox(height: 16),
            _buildWorkDetailsCard(),
            const SizedBox(height: 24),

            // Additional Information
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatusReportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportField('Report Title', task.title),
          const SizedBox(height: 16),
          _buildReportField(
            'Description',
            'Completed gas refill and fixed door seal problems. All issues have been resolved successfully.',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportField(
            'Work Completed',
            'Replaced the door seal gasket and refilled the refrigerant gas. Tested the cooling system and verified proper operation.',
          ),
          const SizedBox(height: 16),
          _buildReportField('Time Spent', '2 hours 30 minutes'),
          const SizedBox(height: 16),
          _buildReportField(
            'Materials Used',
            '• Door seal gasket (1 unit)\n• Refrigerant gas R134a (500g)\n• Thread sealant',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportField(
            'Issues Encountered',
            'Minor difficulty accessing the gas valve due to tight space. Had to use extension tools.',
          ),
          const SizedBox(height: 16),
          _buildReportField(
            'Recommendations',
            'Schedule regular maintenance every 6 months to prevent future gas leaks. Consider relocating the fridge to allow better access for maintenance.',
          ),
        ],
      ),
    );
  }

  Widget _buildReportField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;
    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        text = 'LOW PRIORITY';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = 'MEDIUM PRIORITY';
        break;
      case TaskPriority.high:
        color = Colors.red;
        text = 'HIGH PRIORITY';
        break;
      case TaskPriority.urgent:
        color = Colors.red.shade700;
        text = 'URGENT PRIORITY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFFA726)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
