import '../models/meal_model.dart';
import '../models/streak_data.dart';
import 'progressly_database.dart';

class MealDao {
  final _db = ProgresslyDatabase.instance;

  Future<int> insertMeal(MealModel meal) async {
    final db = await _db.database;
    return await db.insert('meals', meal.toMap());
  }

  Future<List<MealModel>> getAllMeals() async {
    final db = await _db.database;
    final result = await db.query('meals', orderBy: 'loggedDate DESC');
    return result.map((json) => MealModel.fromMap(json)).toList();
  }

  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'meals',
      where: 'loggedDate LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'loggedDate DESC',
    );
    return result.map((json) => MealModel.fromMap(json)).toList();
  }

  Future<int> getTotalCalories(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meals WHERE loggedDate LIKE ?',
      ['$dateStr%'],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> deleteMeal(int id) async {
    final db = await _db.database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  // Meal Streaks
  Future<int> updateMealStreak(DateTime date, StreakData streak) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final data = {
      'date': dateStr,
      'currentStreak': streak.dailyStreak,
      'longestStreak': streak.longestStreak,
      'weeklyStreak': streak.weeklyStreak,
    };

    final existing = await db.query(
      'meal_streaks',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isEmpty) {
      return await db.insert('meal_streaks', data);
    } else {
      return await db.update(
        'meal_streaks',
        data,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  Future<StreakData?> getMealStreak(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'meal_streaks',
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
