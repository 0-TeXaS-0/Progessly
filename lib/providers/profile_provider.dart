import 'package:flutter/foundation.dart';
import '../data/preferences/preferences_manager.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/streak_data.dart';

class ProfileProvider with ChangeNotifier {
  final PreferencesManager _prefs;
  final TaskRepository _taskRepo = TaskRepository();
  final MealRepository _mealRepo = MealRepository();
  final WaterRepository _waterRepo = WaterRepository();
  final HabitRepository _habitRepo = HabitRepository();

  UserProfile? _profile;
  StreakData _taskStreak = StreakData();
  StreakData _mealStreak = StreakData();
  StreakData _waterStreak = StreakData();
  int _tasksCompleted = 0;
  int _mealsLogged = 0;
  int _waterIntake = 0;
  int _habitsCompleted = 0;
  int _totalCalories = 0;
  bool _isLoading = false;

  ProfileProvider(this._prefs);

  UserProfile? get profile => _profile;
  StreakData get taskStreak => _taskStreak;
  StreakData get mealStreak => _mealStreak;
  StreakData get waterStreak => _waterStreak;
  int get tasksCompleted => _tasksCompleted;
  int get mealsLogged => _mealsLogged;
  int get waterIntake => _waterIntake;
  int get habitsCompleted => _habitsCompleted;
  int get totalCalories => _totalCalories;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = _prefs.getUserProfile();
      await loadDailySummary();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailySummary() async {
    try {
      final today = DateTime.now();

      _tasksCompleted = await _taskRepo.getCompletedCount(today);
      _mealsLogged = (await _mealRepo.getMealsByDate(today)).length;
      _waterIntake = await _waterRepo.getTotalIntake(today);
      _habitsCompleted = await _habitRepo.getCompletedCount(today);
      _totalCalories = await _mealRepo.getTotalCalories(today);

      _taskStreak = await _taskRepo.calculateStreak();
      _mealStreak = await _mealRepo.calculateStreak();
      _waterStreak = await _waterRepo.calculateStreak(
        _prefs.getDailyWaterGoal(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily summary: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _prefs.saveUserProfile(profile);
      _profile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
