import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/habit_model.dart';
import '../data/models/streak_data.dart';
import '../data/preferences/notification_preferences.dart';
import '../services/notification_service.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _notifPrefs;

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
      // Initialize notification preferences
      if (_notifPrefs == null) {
        final prefs = await SharedPreferences.getInstance();
        _notifPrefs = NotificationPreferences(prefs);
      }

      _habits = await _repository.getAllHabits();

      // Load completion status for each habit
      for (var habit in _habits) {
        if (habit.id != null) {
          _completionStatus[habit.id!] = await _repository
              .isHabitCompletedToday(habit.id!);
          _streaks[habit.id!] = await _repository.getStreak(habit.id!);

          // Schedule notification for this habit
          await _scheduleHabitReminder(
            habit.id!,
            habit.name,
            _completionStatus[habit.id!] ?? false,
          );
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

      // Cancel notification for completed habit
      await _notificationService.cancelNotification(
        NotificationService.habitReminderIdStart + habitId,
      );
    } catch (e) {
      debugPrint('Error completing habit: $e');
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _repository.deleteHabit(id);
      await _notificationService.cancelNotification(
        NotificationService.habitReminderIdStart + id,
      );
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

  Future<void> _scheduleHabitReminder(
    int habitId,
    String habitName,
    bool isCompleted,
  ) async {
    if (_notifPrefs == null) return;

    final enabled =
        _notifPrefs!.notificationsEnabled &&
        _notifPrefs!.habitsNotificationsEnabled &&
        !isCompleted;

    await _notificationService.scheduleHabitReminder(
      habitId: habitId,
      habitName: habitName,
      enabled: enabled,
      hour: 9, // Default 9 AM
      minute: 0,
    );
  }
}
