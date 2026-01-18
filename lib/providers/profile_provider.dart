import 'package:flutter/foundation.dart';
import '../data/preferences/preferences_manager.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/streak_data.dart';
import '../ui/widgets/calendar_heatmap.dart';
import '../services/insights_service.dart';

class ProfileProvider with ChangeNotifier {
  final PreferencesManager _prefs;
  final TaskRepository _taskRepo = TaskRepository();
  final MealRepository _mealRepo = MealRepository();
  final WaterRepository _waterRepo = WaterRepository();
  final HabitRepository _habitRepo = HabitRepository();
  final InsightsService _insightsService = InsightsService();

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
  List<ActivityData> _activityData = [];
  List<InsightModel> _insights = [];

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
  List<ActivityData> get activityData => _activityData;
  List<InsightModel> get insights => _insights;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = _prefs.getUserProfile();
      await loadDailySummary();
      await loadActivityData();
      await loadInsights();
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

  // Convenience method for updating profile with individual fields
  Future<void> updateProfileFields({
    String? name,
    String? email,
    int? age,
    double? weight,
    double? height,
    String? goal,
    String? gender,
    String? avatarPath,
  }) async {
    if (_profile == null) return;

    final updatedProfile = _profile!.copyWith(
      name: name,
      email: email,
      age: age,
      weight: weight?.toInt(),
      height: height,
      goal: goal,
      gender: gender,
      avatarPath: avatarPath,
    );

    await updateProfile(updatedProfile);
  }

  // Getters for profile fields
  String get name => _profile?.name ?? '';
  String get email => _profile?.email ?? '';
  int get age => _profile?.age ?? 0;
  int get weight => _profile?.weight ?? 0;
  double get height => _profile?.height ?? 0;
  String get goal => _profile?.goal ?? '';
  String get gender => _profile?.gender ?? '';
  String get avatarPath => _profile?.avatarPath ?? '';

  Future<void> loadActivityData() async {
    try {
      final activities = <ActivityData>[];
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 84)); // 12 weeks

      for (int i = 0; i < 84; i++) {
        final date = startDate.add(Duration(days: i));

        // Don't calculate for future dates
        if (date.isAfter(now)) break;

        // Get data for each category
        final tasksCount = await _taskRepo.getCompletedCount(date);
        final mealsCount = (await _mealRepo.getMealsByDate(date)).length;
        final waterIntake = await _waterRepo.getTotalIntake(date);
        final habitsCount = await _habitRepo.getCompletedCount(date);

        // Calculate intensity (0-100)
        // Assuming daily goals: 5 tasks, 3 meals, water goal, 3 habits
        int totalScore = 0;
        totalScore += (tasksCount * 20).clamp(0, 20); // Max 20 points
        totalScore += (mealsCount * 13).clamp(
          0,
          40,
        ); // Max 40 points (3 meals * 13)
        totalScore += (waterIntake >= _prefs.getDailyWaterGoal()
            ? 20
            : 0); // 20 points if goal met
        totalScore += (habitsCount * 7).clamp(0, 20); // Max 20 points

        activities.add(
          ActivityData(date: date, intensity: totalScore.clamp(0, 100)),
        );
      }

      _activityData = activities;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading activity data: $e');
    }
  }

  Future<void> loadInsights() async {
    try {
      _insights = await _insightsService.generateInsights(
        dailyWaterGoal: _prefs.getDailyWaterGoal(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading insights: $e');
    }
  }
}
