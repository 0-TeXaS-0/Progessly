import '../database/water_dao.dart';
import '../models/water_log_model.dart';
import '../models/streak_data.dart';

class WaterRepository {
  final WaterDao _waterDao = WaterDao();

  Future<int> addWaterLog(WaterLogModel log) async {
    return await _waterDao.insertWaterLog(log);
  }

  Future<List<WaterLogModel>> getWaterLogsByDate(DateTime date) async {
    return await _waterDao.getWaterLogsByDate(date);
  }

  Future<int> getTotalIntake(DateTime date) async {
    return await _waterDao.getTotalWaterIntake(date);
  }

  Future<void> deleteWaterLog(int id) async {
    await _waterDao.deleteWaterLog(id);
  }

  Future<void> updateStreak(
    DateTime date,
    StreakData streak,
    int dailyGoal,
  ) async {
    await _waterDao.updateWaterStreak(date, streak, dailyGoal);
  }

  Future<StreakData> getStreak(DateTime date) async {
    final streak = await _waterDao.getWaterStreak(date);
    return streak ?? StreakData();
  }

  Future<int> getDailyGoal(DateTime date) async {
    final goal = await _waterDao.getDailyGoal(date);
    return goal ?? 2000;
  }

  Future<StreakData> calculateStreak(int dailyGoal) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayIntake = await getTotalIntake(today);
    final yesterdayStreak = await getStreak(yesterday);

    int currentStreak = 0;
    if (todayIntake >= dailyGoal) {
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
        final intake = await getTotalIntake(day);
        final goal = await getDailyGoal(day);
        if (intake >= goal) weeklyCount++;
      }
    }

    return StreakData(
      dailyStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyStreak: weeklyCount,
    );
  }
}
