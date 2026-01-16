import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyWaterEnabled = 'water_notifications_enabled';
  static const String _keyTasksEnabled = 'tasks_notifications_enabled';
  static const String _keyMealsEnabled = 'meals_notifications_enabled';
  static const String _keyHabitsEnabled = 'habits_notifications_enabled';
  static const String _keyStreakEnabled = 'streak_notifications_enabled';
  static const String _keyWaterInterval = 'water_reminder_interval_hours';

  final SharedPreferences _prefs;

  NotificationPreferences(this._prefs);

  // Master toggle
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // Category toggles
  bool get waterNotificationsEnabled =>
      _prefs.getBool(_keyWaterEnabled) ?? true;

  Future<void> setWaterNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyWaterEnabled, enabled);
  }

  bool get tasksNotificationsEnabled =>
      _prefs.getBool(_keyTasksEnabled) ?? true;

  Future<void> setTasksNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyTasksEnabled, enabled);
  }

  bool get mealsNotificationsEnabled =>
      _prefs.getBool(_keyMealsEnabled) ?? true;

  Future<void> setMealsNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyMealsEnabled, enabled);
  }

  bool get habitsNotificationsEnabled =>
      _prefs.getBool(_keyHabitsEnabled) ?? true;

  Future<void> setHabitsNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyHabitsEnabled, enabled);
  }

  bool get streakNotificationsEnabled =>
      _prefs.getBool(_keyStreakEnabled) ?? true;

  Future<void> setStreakNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyStreakEnabled, enabled);
  }

  // Water reminder interval
  int get waterReminderIntervalHours => _prefs.getInt(_keyWaterInterval) ?? 2;

  Future<void> setWaterReminderIntervalHours(int hours) async {
    await _prefs.setInt(_keyWaterInterval, hours);
  }

  // Check if any notifications are enabled
  bool get hasAnyNotificationsEnabled {
    return notificationsEnabled &&
        (waterNotificationsEnabled ||
            tasksNotificationsEnabled ||
            mealsNotificationsEnabled ||
            habitsNotificationsEnabled ||
            streakNotificationsEnabled);
  }
}
