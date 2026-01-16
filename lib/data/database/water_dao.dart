import '../models/water_log_model.dart';
import '../models/streak_data.dart';
import 'progressly_database.dart';

class WaterDao {
  final _db = ProgresslyDatabase.instance;

  Future<int> insertWaterLog(WaterLogModel log) async {
    final db = await _db.database;
    return await db.insert('water_logs', log.toMap());
  }

  Future<List<WaterLogModel>> getWaterLogsByDate(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'water_logs',
      where: 'loggedDate LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'loggedDate DESC',
    );
    return result.map((json) => WaterLogModel.fromMap(json)).toList();
  }

  Future<int> getTotalWaterIntake(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM water_logs WHERE loggedDate LIKE ?',
      ['$dateStr%'],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> deleteWaterLog(int id) async {
    final db = await _db.database;
    return await db.delete('water_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Water Streaks
  Future<int> updateWaterStreak(
    DateTime date,
    StreakData streak,
    int dailyGoal,
  ) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final data = {
      'date': dateStr,
      'currentStreak': streak.dailyStreak,
      'longestStreak': streak.longestStreak,
      'weeklyStreak': streak.weeklyStreak,
      'dailyGoal': dailyGoal,
    };

    final existing = await db.query(
      'water_streaks',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isEmpty) {
      return await db.insert('water_streaks', data);
    } else {
      return await db.update(
        'water_streaks',
        data,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  Future<StreakData?> getWaterStreak(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'water_streaks',
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

  Future<int?> getDailyGoal(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'water_streaks',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (result.isEmpty) return null;
    return result.first['dailyGoal'] as int?;
  }
}
