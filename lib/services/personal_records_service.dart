import '../data/models/personal_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PersonalRecordsService {
  static const String _storageKey = 'personal_records';

  // Check and update personal records based on daily activity
  static Future<List<PersonalRecord>> checkAndUpdateRecords({
    required int tasksCompleted,
    required double waterIntake,
    required int mealsLogged,
    required int habitsCompleted,
    required int currentStreak,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    final newRecords = <PersonalRecord>[];
    final now = DateTime.now();

    // Task completion record
    final taskRecord = records.where((r) => r.category == 'task').firstOrNull;
    if (taskRecord == null || tasksCompleted > taskRecord.value) {
      final record = PersonalRecord(
        id: 'task_record',
        category: 'task',
        title: 'Most Tasks Completed',
        value: tasksCompleted.toDouble(),
        unit: 'tasks',
        achievedDate: now,
        description: 'Completed $tasksCompleted tasks in a single day',
      );
      newRecords.add(record);
      await _updateRecord(prefs, record);
    }

    // Water intake record
    final waterRecord = records.where((r) => r.category == 'water').firstOrNull;
    if (waterRecord == null || waterIntake > waterRecord.value) {
      final record = PersonalRecord(
        id: 'water_record',
        category: 'water',
        title: 'Most Water Consumed',
        value: waterIntake,
        unit: 'ml',
        achievedDate: now,
        description: 'Drank ${waterIntake.toInt()}ml of water in a single day',
      );
      newRecords.add(record);
      await _updateRecord(prefs, record);
    }

    // Meal logging record
    final mealRecord = records.where((r) => r.category == 'meal').firstOrNull;
    if (mealRecord == null || mealsLogged > mealRecord.value) {
      final record = PersonalRecord(
        id: 'meal_record',
        category: 'meal',
        title: 'Most Meals Logged',
        value: mealsLogged.toDouble(),
        unit: 'meals',
        achievedDate: now,
        description: 'Logged $mealsLogged meals in a single day',
      );
      newRecords.add(record);
      await _updateRecord(prefs, record);
    }

    // Habit completion record
    final habitRecord = records.where((r) => r.category == 'habit').firstOrNull;
    if (habitRecord == null || habitsCompleted > habitRecord.value) {
      final record = PersonalRecord(
        id: 'habit_record',
        category: 'habit',
        title: 'Most Habits Completed',
        value: habitsCompleted.toDouble(),
        unit: 'habits',
        achievedDate: now,
        description: 'Completed $habitsCompleted habits in a single day',
      );
      newRecords.add(record);
      await _updateRecord(prefs, record);
    }

    // Streak record
    final streakRecord = records
        .where((r) => r.category == 'streak')
        .firstOrNull;
    if (streakRecord == null || currentStreak > streakRecord.value) {
      final record = PersonalRecord(
        id: 'streak_record',
        category: 'streak',
        title: 'Longest Streak',
        value: currentStreak.toDouble(),
        unit: 'days',
        achievedDate: now,
        description: 'Maintained a streak for $currentStreak days',
      );
      newRecords.add(record);
      await _updateRecord(prefs, record);
    }

    return newRecords;
  }

  static Future<List<PersonalRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(_storageKey) ?? [];
    return recordsJson
        .map((json) => PersonalRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> _updateRecord(
    SharedPreferences prefs,
    PersonalRecord record,
  ) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == record.id);
    records.add(record);

    final recordsJson = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, recordsJson);
  }

  static Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
