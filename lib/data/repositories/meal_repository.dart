import '../database/meal_dao.dart';
import '../models/meal_model.dart';
import '../models/meal_template_model.dart';
import '../models/streak_data.dart';
import '../database/progressly_database.dart';

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

  // ========== MEAL TEMPLATES ==========

  Future<int> addTemplate(MealTemplateModel template) async {
    final db = await ProgresslyDatabase.instance.database;
    return await db.insert('meal_templates', template.toMap());
  }

  Future<List<MealTemplateModel>> getAllTemplates() async {
    final db = await ProgresslyDatabase.instance.database;
    final maps = await db.query('meal_templates', orderBy: 'name ASC');
    return maps.map((map) => MealTemplateModel.fromMap(map)).toList();
  }

  Future<List<MealTemplateModel>> getTemplatesByMealType(
    String mealType,
  ) async {
    final db = await ProgresslyDatabase.instance.database;
    final maps = await db.query(
      'meal_templates',
      where: 'mealType = ?',
      whereArgs: [mealType],
      orderBy: 'timesLogged DESC, name ASC',
    );
    return maps.map((map) => MealTemplateModel.fromMap(map)).toList();
  }

  Future<List<MealTemplateModel>> getFavoriteTemplates() async {
    final db = await ProgresslyDatabase.instance.database;
    final maps = await db.query(
      'meal_templates',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'timesLogged DESC',
    );
    return maps.map((map) => MealTemplateModel.fromMap(map)).toList();
  }

  Future<void> updateTemplate(MealTemplateModel template) async {
    final db = await ProgresslyDatabase.instance.database;
    await db.update(
      'meal_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> deleteTemplate(int id) async {
    final db = await ProgresslyDatabase.instance.database;
    await db.delete('meal_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementTemplateUsage(int templateId) async {
    final db = await ProgresslyDatabase.instance.database;
    await db.rawUpdate(
      '''
      UPDATE meal_templates 
      SET timesLogged = timesLogged + 1 
      WHERE id = ?
    ''',
      [templateId],
    );
  }

  Future<MealModel> logFromTemplate(MealTemplateModel template) async {
    final meal = MealModel(
      name: template.name,
      calories: template.calories,
      mealType: template.mealType,
      time: _getCurrentTime(),
    );

    final mealId = await addMeal(meal);
    await incrementTemplateUsage(template.id!);

    return meal.copyWith(id: mealId);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
