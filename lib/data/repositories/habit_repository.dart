import '../database/habit_dao.dart';
import '../models/habit_model.dart';
import '../models/streak_data.dart';

class HabitRepository {
  final HabitDao _habitDao = HabitDao();

  // Habits
  Future<int> addHabit(HabitModel habit) async {
    return await _habitDao.insertHabit(habit);
  }

  Future<List<HabitModel>> getAllHabits() async {
    return await _habitDao.getAllHabits();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitDao.updateHabit(habit);
  }

  Future<void> deleteHabit(int id) async {
    await _habitDao.deleteHabit(id);
  }

  // Habit Logs
  Future<int> completeHabit(int habitId) async {
    final log = HabitLogModel(habitId: habitId);
    return await _habitDao.insertHabitLog(log);
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    return await _habitDao.isHabitCompletedToday(habitId, DateTime.now());
  }

  Future<List<HabitLogModel>> getHabitLogs(int habitId) async {
    return await _habitDao.getHabitLogsForHabit(habitId);
  }

  Future<int> getCompletedCount(DateTime date) async {
    return await _habitDao.getCompletedHabitsCount(date);
  }

  // Streaks
  Future<void> updateStreak(int habitId, StreakData streak) async {
    await _habitDao.updateHabitStreak(habitId, streak, DateTime.now());
  }

  Future<StreakData> getStreak(int habitId) async {
    final streak = await _habitDao.getHabitStreak(habitId);
    return streak ?? StreakData();
  }

  Future<StreakData> calculateStreak(int habitId) async {
    final logs = await getHabitLogs(habitId);

    if (logs.isEmpty) {
      return StreakData();
    }

    // Sort logs by date descending
    logs.sort((a, b) => b.completedDate.compareTo(a.completedDate));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    DateTime? lastDate = logs.first.completedDate;

    // Check if completed today or yesterday
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );

    if (lastDateOnly.isAtSameMomentAs(todayOnly) ||
        lastDateOnly.isAtSameMomentAs(yesterdayOnly)) {
      currentStreak = 1;

      // Calculate streak
      for (int i = 1; i < logs.length; i++) {
        final currentLog = logs[i];
        final prevLog = logs[i - 1];

        final currentDay = DateTime(
          currentLog.completedDate.year,
          currentLog.completedDate.month,
          currentLog.completedDate.day,
        );
        final prevDay = DateTime(
          prevLog.completedDate.year,
          prevLog.completedDate.month,
          prevLog.completedDate.day,
        );

        final diff = prevDay.difference(currentDay).inDays;

        if (diff == 1) {
          currentStreak++;
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
    }

    longestStreak = currentStreak > longestStreak
        ? currentStreak
        : longestStreak;

    // Calculate weekly streak
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    int weeklyCount = 0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (day.isBefore(today.add(const Duration(days: 1)))) {
        final isCompleted = await _habitDao.isHabitCompletedToday(habitId, day);
        if (isCompleted) weeklyCount++;
      }
    }

    return StreakData(
      dailyStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyStreak: weeklyCount,
    );
  }
}
