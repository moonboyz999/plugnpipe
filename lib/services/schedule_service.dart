import 'task_service.dart';
import '../screens/tech/my_schedule_screen.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  final List<ScheduledTask> _scheduledTasks = [];

  List<ScheduledTask> get scheduledTasks => List.unmodifiable(_scheduledTasks);

  void addTaskToSchedule(ServiceTask task, String scheduledTime) {
    final scheduledTask = ScheduledTask(
      task: task,
      scheduledTime: scheduledTime,
      status: ScheduleStatus.scheduled,
    );

    _scheduledTasks.add(scheduledTask);
  }

  void updateTaskStatus(String taskId, ScheduleStatus status) {
    final index = _scheduledTasks.indexWhere((st) => st.task.id == taskId);
    if (index != -1) {
      final existingTask = _scheduledTasks[index];
      _scheduledTasks[index] = ScheduledTask(
        task: existingTask.task,
        scheduledTime: existingTask.scheduledTime,
        status: status,
      );
    }
  }

  void removeTaskFromSchedule(String taskId) {
    _scheduledTasks.removeWhere((st) => st.task.id == taskId);
  }

  List<ScheduledTask> getTasksForDate(DateTime date) {
    // For now, return all tasks (can be enhanced to filter by date)
    return _scheduledTasks;
  }
}
