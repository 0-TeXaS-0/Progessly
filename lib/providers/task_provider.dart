import 'package:flutter/foundation.dart';
import '../data/repositories/task_repository.dart';
import '../data/models/task_model.dart';
import '../data/models/streak_data.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<TaskModel> _tasks = [];
  StreakData _streak = StreakData();
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  StreakData get streak => _streak;
  bool get isLoading => _isLoading;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks();
      await loadStreak();
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
}
