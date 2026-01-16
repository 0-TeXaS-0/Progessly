import 'package:flutter/foundation.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/habit_model.dart';
import '../data/models/streak_data.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository = HabitRepository();

  List<HabitModel> _habits = [];
  final Map<int, bool> _completionStatus = {};
  final Map<int, StreakData> _streaks = {};
  bool _isLoading = false;

  List<HabitModel> get habits => _habits;
  Map<int, bool> get completionStatus => _completionStatus;
  Map<int, StreakData> get streaks => _streaks;
  bool get isLoading => _isLoading;
  int get completedCount => _completionStatus.values.where((c) => c).length;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.getAllHabits();

      // Load completion status for each habit
      for (var habit in _habits) {
        if (habit.id != null) {
          _completionStatus[habit.id!] = await _repository
              .isHabitCompletedToday(habit.id!);
          _streaks[habit.id!] = await _repository.getStreak(habit.id!);
        }
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(
    String name, {
    String description = '',
    String category = 'General',
  }) async {
    try {
      final habit = HabitModel(
        name: name,
        description: description,
        category: category,
      );

      await _repository.addHabit(habit);
      await loadHabits();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> completeHabit(int habitId) async {
    try {
      await _repository.completeHabit(habitId);

      // Update streak
      final streak = await _repository.calculateStreak(habitId);
      await _repository.updateStreak(habitId, streak);

      await loadHabits();
    } catch (e) {
      debugPrint('Error completing habit: $e');
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _repository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  StreakData getStreakForHabit(int habitId) {
    return _streaks[habitId] ?? StreakData();
  }

  bool isHabitCompleted(int habitId) {
    return _completionStatus[habitId] ?? false;
  }
}
