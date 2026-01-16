import '../models/task_model.dart';
import '../models/streak_data.dart';
import 'progressly_database.dart';

class TaskDao {
  final _db = ProgresslyDatabase.instance;

  Future<int> insertTask(TaskModel task) async {
    final db = await _db.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _db.database;
    final result = await db.query('tasks', orderBy: 'createdDate DESC');
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'tasks',
      where: 'createdDate LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<int> getCompletedTasksCount(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'tasks',
      where: 'isCompleted = 1 AND completedDate LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return result.length;
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await _db.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _db.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Task Streaks
  Future<int> updateTaskStreak(DateTime date, StreakData streak) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final data = {
      'date': dateStr,
      'currentStreak': streak.dailyStreak,
      'longestStreak': streak.longestStreak,
      'weeklyStreak': streak.weeklyStreak,
    };

    final existing = await db.query(
      'task_streaks',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isEmpty) {
      return await db.insert('task_streaks', data);
    } else {
      return await db.update(
        'task_streaks',
        data,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  Future<StreakData?> getTaskStreak(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'task_streaks',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (result.isEmpty) return null;
    final map = result.first;
    return StreakData(
      dailyStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      weeklyStreak: map['weeklyStreak'] as int,
    );
  }
}
