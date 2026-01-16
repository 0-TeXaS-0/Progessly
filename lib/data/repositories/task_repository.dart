import '../database/task_dao.dart';
import '../models/task_model.dart';
import '../models/streak_data.dart';

class TaskRepository {
  final TaskDao _taskDao = TaskDao();

  Future<int> addTask(TaskModel task) async {
    return await _taskDao.insertTask(task);
  }

  Future<List<TaskModel>> getTasks() async {
    return await _taskDao.getAllTasks();
  }

  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    return await _taskDao.getTasksByDate(date);
  }

  Future<int> getCompletedCount(DateTime date) async {
    return await _taskDao.getCompletedTasksCount(date);
  }

  Future<void> completeTask(TaskModel task) async {
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
    );
    await _taskDao.updateTask(updatedTask);
  }

  Future<void> uncompleteTask(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: false, completedDate: null);
    await _taskDao.updateTask(updatedTask);
  }

  Future<void> deleteTask(int id) async {
    await _taskDao.deleteTask(id);
  }

  Future<void> updateStreak(DateTime date, StreakData streak) async {
    await _taskDao.updateTaskStreak(date, streak);
  }

  Future<StreakData> getStreak(DateTime date) async {
    final streak = await _taskDao.getTaskStreak(date);
    return streak ?? StreakData();
  }

  Future<StreakData> calculateStreak() async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayCompleted = await getCompletedCount(today);
    final yesterdayStreak = await getStreak(yesterday);

    int currentStreak = 0;
    if (todayCompleted > 0) {
      currentStreak = yesterdayStreak.dailyStreak + 1;
    }

    final longestStreak = currentStreak > yesterdayStreak.longestStreak
        ? currentStreak
        : yesterdayStreak.longestStreak;

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    int weeklyCount = 0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (day.isBefore(today.add(const Duration(days: 1)))) {
        final count = await getCompletedCount(day);
        if (count > 0) weeklyCount++;
      }
    }

    return StreakData(
      dailyStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyStreak: weeklyCount,
    );
  }
}
