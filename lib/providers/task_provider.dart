import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/task_repository.dart';
import '../data/models/task_model.dart';
import '../data/models/streak_data.dart';
import '../data/preferences/notification_preferences.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _notifPrefs;

  List<TaskModel> _tasks = [];
  StreakData _streak = StreakData();
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  StreakData get streak => _streak;
  bool get isLoading => _isLoading;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize notification preferences
      if (_notifPrefs == null) {
        final prefs = await SharedPreferences.getInstance();
        _notifPrefs = NotificationPreferences(prefs);
      }

      _tasks = await _repository.getTasks();
      await loadStreak();
      await _scheduleTaskReminders();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStreak() async {
    try {
      _streak = await _repository.calculateStreak();
      await _repository.updateStreak(DateTime.now(), _streak);
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> addTask(
    String title, {
    String description = '',
    String category = 'General',
  }) async {
    try {
      final task = TaskModel(
        title: title,
        description: description,
        category: category,
      );

      await _repository.addTask(task);
      await loadTasks();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> addTaskModel(TaskModel task) async {
    try {
      await _repository.addTask(task);
      await loadTasks();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    try {
      if (task.isCompleted) {
        await _repository.uncompleteTask(task);
      } else {
        await _repository.completeTask(task);
      }
      await loadTasks();
    } catch (e) {
      debugPrint('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> _scheduleTaskReminders() async {
    if (_notifPrefs == null) return;

    final enabled =
        _notifPrefs!.notificationsEnabled &&
        _notifPrefs!.tasksNotificationsEnabled;

    await _notificationService.scheduleTaskReminders(
      enabled: enabled,
      pendingTasks: pendingCount,
    );
  }
}
