import 'package:flutter/material.dart';
import '../../services/task_service.dart';

class StatusReportScreen extends StatefulWidget {
  final ServiceTask task;

  const StatusReportScreen({super.key, required this.task});

  @override
  State<StatusReportScreen> createState() => _StatusReportScreenState();
}

class _StatusReportScreenState extends State<StatusReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workCompletedController = TextEditingController();
  final _timeSpentController = TextEditingController();
  final _materialsUsedController = TextEditingController();
  final _issuesEncounteredController = TextEditingController();
  final _recommendationsController = TextEditingController();

  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _reportTitleController.text = widget.task.title;
    _timeSpentController.text = '2 hours 30 minutes';

    // Load existing draft if available
    _loadExistingDraft();
  }

  void _loadExistingDraft() {
    final existingReport = _taskService.getReport(widget.task.id);
    if (existingReport != null && !existingReport.isSubmitted) {
      // Load draft data into form fields
      _workCompletedController.text = existingReport.workCompleted;
      _materialsUsedController.text = existingReport.materialsUsed;
      _issuesEncounteredController.text = existingReport.issuesEncountered;
      _recommendationsController.text = existingReport.recommendations;
    }
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _descriptionController.dispose();
    _workCompletedController.dispose();
    _timeSpentController.dispose();
    _materialsUsedController.dispose();
    _issuesEncounteredController.dispose();
    _recommendationsController.dispose();
    super.dispose();
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
                        'Edit Status Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'Complete your status report',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Report Information'),
              const SizedBox(height: 16),
              _buildTextField(
                'Report Title',
                _reportTitleController,
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Description',
                _descriptionController,
                placeholder: 'Brief description of the work',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Work Details'),
              const SizedBox(height: 16),
              _buildTextField(
                'Work Completed',
                _workCompletedController,
                placeholder: 'Describe the work that was completed',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Time Spent',
                _timeSpentController,
                placeholder: 'e.g., 2 hours 30 minutes',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Materials Used',
                _materialsUsedController,
                placeholder: 'List any materials or parts used',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Additional Information'),
              const SizedBox(height: 16),
              _buildTextField(
                'Issues Encountered',
                _issuesEncounteredController,
                placeholder: 'Describe any problems or challenges',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Recommendations',
                _recommendationsController,
                placeholder: 'Any recommendations for future maintenance',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDraft,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Save Draft',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? placeholder,
    int maxLines = 1,
    bool enabled = true,
  }) {
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
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _saveDraft() {
    // Create draft report
    final draftReport = StatusReport(
      id: 'DRAFT_${widget.task.id}_${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task.id,
      workCompleted: _workCompletedController.text,
      materialsUsed: _materialsUsedController.text,
      issuesEncountered: _issuesEncounteredController.text,
      recommendations: _recommendationsController.text,
      createdAt: DateTime.now(),
      isSubmitted: false,
    );

    // Save draft using TaskService
    _taskService.saveDraftReport(widget.task.id, draftReport);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draft saved successfully! You can continue editing later.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Create final report
      final finalReport = StatusReport(
        id: 'REPORT_${widget.task.id}_${DateTime.now().millisecondsSinceEpoch}',
        taskId: widget.task.id,
        workCompleted: _workCompletedController.text,
        materialsUsed: _materialsUsedController.text,
        issuesEncountered: _issuesEncounteredController.text,
        recommendations: _recommendationsController.text,
        createdAt: DateTime.now(),
        isSubmitted: true,
      );

      // Submit report using TaskService
      _taskService.submitReport(widget.task.id, finalReport);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Status report submitted successfully! Task moved to work history.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to task list (pop twice to go back from detail screen)
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
