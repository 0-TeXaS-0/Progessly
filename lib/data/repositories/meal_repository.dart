import '../database/meal_dao.dart';
import '../models/meal_model.dart';
import '../models/streak_data.dart';

class MealRepository {
  final MealDao _mealDao = MealDao();

  Future<int> addMeal(MealModel meal) async {
    return await _mealDao.insertMeal(meal);
  }

  Future<List<MealModel>> getAllMeals() async {
    return await _mealDao.getAllMeals();
  }

  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    return await _mealDao.getMealsByDate(date);
  }

  Future<int> getTotalCalories(DateTime date) async {
    return await _mealDao.getTotalCalories(date);
  }

  Future<void> deleteMeal(int id) async {
    await _mealDao.deleteMeal(id);
  }

  Future<void> updateStreak(DateTime date, StreakData streak) async {
    await _mealDao.updateMealStreak(date, streak);
  }

  Future<StreakData> getStreak(DateTime date) async {
    final streak = await _mealDao.getMealStreak(date);
    return streak ?? StreakData();
  }

  Future<StreakData> calculateStreak() async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayMeals = await getMealsByDate(today);
    final yesterdayStreak = await getStreak(yesterday);

    int currentStreak = 0;
    if (todayMeals.isNotEmpty) {
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
        final meals = await getMealsByDate(day);
        if (meals.isNotEmpty) weeklyCount++;
      }
    }

    return StreakData(
      dailyStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyStreak: weeklyCount,
    );
  }
}
