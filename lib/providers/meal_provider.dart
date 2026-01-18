import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/meal_repository.dart';
import '../data/models/meal_model.dart';
import '../data/models/meal_template_model.dart';
import '../data/models/streak_data.dart';
import '../data/preferences/notification_preferences.dart';
import '../services/notification_service.dart';

class MealProvider with ChangeNotifier {
  final MealRepository _repository = MealRepository();
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _notifPrefs;

  List<MealModel> _meals = [];
  List<MealTemplateModel> _templates = [];
  StreakData _streak = StreakData();
  int _totalCalories = 0;
  bool _isLoading = false;

  List<MealModel> get meals => _meals;
  List<MealTemplateModel> get templates => _templates;
  StreakData get streak => _streak;
  int get totalCalories => _totalCalories;
  bool get isLoading => _isLoading;
  int get mealCount => _meals.length;

  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize notification preferences
      if (_notifPrefs == null) {
        final prefs = await SharedPreferences.getInstance();
        _notifPrefs = NotificationPreferences(prefs);
        await _scheduleMealReminders();
      }

      final today = DateTime.now();
      _meals = await _repository.getMealsByDate(today);
      _totalCalories = await _repository.getTotalCalories(today);
      _templates = await _repository.getAllTemplates();
      await loadStreak();
    } catch (e) {
      debugPrint('Error loading meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStreak() async {
    try {
      _streak = await _repository.calculateStreak();
      await _repository.updateStreak(DateTime.now(), _streak);
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> addMeal(String name, int calories, String mealType) async {
    try {
      final meal = MealModel(
        name: name,
        calories: calories,
        mealType: mealType,
        time: _getCurrentTime(),
      );

      await _repository.addMeal(meal);
      await loadMeals();
    } catch (e) {
      debugPrint('Error adding meal: $e');
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _repository.deleteMeal(id);
      await loadMeals();
    } catch (e) {
      debugPrint('Error deleting meal: $e');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _scheduleMealReminders() async {
    if (_notifPrefs == null) return;

    final enabled =
        _notifPrefs!.notificationsEnabled &&
        _notifPrefs!.mealsNotificationsEnabled;

    await _notificationService.scheduleMealReminders(enabled: enabled);
  }

  // ========== TEMPLATE METHODS ==========

  List<MealTemplateModel> getTemplatesByType(String mealType) {
    return _templates.where((t) => t.mealType == mealType).toList()
      ..sort((a, b) => b.timesLogged.compareTo(a.timesLogged));
  }

  String getSuggestedMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'Breakfast';
    if (hour >= 11 && hour < 16) return 'Lunch';
    if (hour >= 16 && hour < 21) return 'Dinner';
    return 'Snack';
  }

  Future<void> addTemplate(String name, int calories, String mealType) async {
    try {
      final template = MealTemplateModel(
        name: name,
        calories: calories,
        mealType: mealType,
      );

      await _repository.addTemplate(template);
      await loadMeals(); // Reload to get updated templates
    } catch (e) {
      debugPrint('Error adding template: $e');
    }
  }

  Future<void> updateTemplate(MealTemplateModel template) async {
    try {
      await _repository.updateTemplate(template);
      await loadMeals();
    } catch (e) {
      debugPrint('Error updating template: $e');
    }
  }

  Future<void> deleteTemplate(int id) async {
    try {
      await _repository.deleteTemplate(id);
      await loadMeals();
    } catch (e) {
      debugPrint('Error deleting template: $e');
    }
  }

  Future<void> logFromTemplate(MealTemplateModel template) async {
    try {
      await _repository.logFromTemplate(template);
      await loadMeals();
    } catch (e) {
      debugPrint('Error logging from template: $e');
    }
  }

  Future<void> toggleTemplateFavorite(MealTemplateModel template) async {
    try {
      final updated = template.copyWith(isFavorite: !template.isFavorite);
      await _repository.updateTemplate(updated);
      await loadMeals();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }
}

class TimeOfDay {
  static TimeOfDay now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  String format(dynamic context) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
