import '../models/habit_model.dart';
import '../models/streak_data.dart';
import 'progressly_database.dart';

class HabitDao {
  final _db = ProgresslyDatabase.instance;

  // Habits
  Future<int> insertHabit(HabitModel habit) async {
    final db = await _db.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<HabitModel>> getAllHabits() async {
    final db = await _db.database;
    final result = await db.query('habits', orderBy: 'createdDate DESC');
    return result.map((json) => HabitModel.fromMap(json)).toList();
  }

  Future<int> updateHabit(HabitModel habit) async {
    final db = await _db.database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await _db.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // Habit Logs
  Future<int> insertHabitLog(HabitLogModel log) async {
    final db = await _db.database;
    return await db.insert('habit_logs', log.toMap());
  }

  Future<List<HabitLogModel>> getHabitLogsByDate(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'habit_logs',
      where: 'completedDate LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return result.map((json) => HabitLogModel.fromMap(json)).toList();
  }

  Future<List<HabitLogModel>> getHabitLogsForHabit(int habitId) async {
    final db = await _db.database;
    final result = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completedDate DESC',
    );
    return result.map((json) => HabitLogModel.fromMap(json)).toList();
  }

  Future<bool> isHabitCompletedToday(int habitId, DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'habit_logs',
      where: 'habitId = ? AND completedDate LIKE ?',
      whereArgs: [habitId, '$dateStr%'],
    );
    return result.isNotEmpty;
  }

  Future<int> getCompletedHabitsCount(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT habitId) as count FROM habit_logs WHERE completedDate LIKE ?',
      ['$dateStr%'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Habit Streaks
  Future<int> updateHabitStreak(
    int habitId,
    StreakData streak,
    DateTime? lastCompleted,
  ) async {
    final db = await _db.database;
    final data = {
      'habitId': habitId,
      'currentStreak': streak.dailyStreak,
      'longestStreak': streak.longestStreak,
      'weeklyStreak': streak.weeklyStreak,
      'lastCompletedDate': lastCompleted?.toIso8601String(),
    };

    final existing = await db.query(
      'habit_streaks',
      where: 'habitId = ?',
      whereArgs: [habitId],
    );

    if (existing.isEmpty) {
      return await db.insert('habit_streaks', data);
    } else {
      return await db.update(
        'habit_streaks',
        data,
        where: 'habitId = ?',
        whereArgs: [habitId],
      );
    }
  }

  Future<StreakData?> getHabitStreak(int habitId) async {
    final db = await _db.database;
    final result = await db.query(
      'habit_streaks',
      where: 'habitId = ?',
      whereArgs: [habitId],
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
