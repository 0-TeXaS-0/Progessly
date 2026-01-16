import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/meal_repository.dart';
import '../data/models/meal_model.dart';
import '../data/models/streak_data.dart';
import '../data/preferences/notification_preferences.dart';
import '../services/notification_service.dart';

class MealProvider with ChangeNotifier {
  final MealRepository _repository = MealRepository();
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _notifPrefs;

  List<MealModel> _meals = [];
  StreakData _streak = StreakData();
  int _totalCalories = 0;
  bool _isLoading = false;

  List<MealModel> get meals => _meals;
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
