import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/water_repository.dart';
import '../data/models/water_log_model.dart';
import '../data/models/streak_data.dart';
import '../data/preferences/preferences_manager.dart';
import '../data/preferences/notification_preferences.dart';
import '../services/notification_service.dart';

class WaterProvider with ChangeNotifier {
  final WaterRepository _repository = WaterRepository();
  final PreferencesManager _prefs;
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _notifPrefs;

  List<WaterLogModel> _logs = [];
  StreakData _streak = StreakData();
  int _totalIntake = 0;
  int _dailyGoal = 2000;
  bool _isLoading = false;

  WaterProvider(this._prefs);

  List<WaterLogModel> get logs => _logs;
  StreakData get streak => _streak;
  int get totalIntake => _totalIntake;
  int get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;
  double get progress =>
      _dailyGoal > 0 ? (_totalIntake / _dailyGoal).clamp(0.0, 1.0) : 0.0;
  int get remaining => (_dailyGoal - _totalIntake).clamp(0, _dailyGoal);

  Future<void> initialize() async {
    final profile = _prefs.getUserProfile();
    if (profile != null) {
      _dailyGoal = _prefs.calculateWaterGoal(profile.weight, profile.gender);
      await _prefs.setDailyWaterGoal(_dailyGoal);
    } else {
      _dailyGoal = _prefs.getDailyWaterGoal();
    }

    // Initialize notification preferences
    final prefs = await SharedPreferences.getInstance();
    _notifPrefs = NotificationPreferences(prefs);

    await loadWaterLogs();
    await _scheduleWaterReminders();
  }

  Future<void> loadWaterLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      _logs = await _repository.getWaterLogsByDate(today);
      _totalIntake = await _repository.getTotalIntake(today);
      await loadStreak();
    } catch (e) {
      debugPrint('Error loading water logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStreak() async {
    try {
      _streak = await _repository.calculateStreak(_dailyGoal);
      await _repository.updateStreak(DateTime.now(), _streak, _dailyGoal);
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> addWater(int amount) async {
    try {
      final log = WaterLogModel(amount: amount, time: _getCurrentTime());

      await _repository.addWaterLog(log);
      await loadWaterLogs();
      await _scheduleWaterReminders();
    } catch (e) {
      debugPrint('Error adding water: $e');
    }
  }

  Future<void> deleteWaterLog(int id) async {
    try {
      await _repository.deleteWaterLog(id);
      await loadWaterLogs();
    } catch (e) {
      debugPrint('Error deleting water log: $e');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void updateGoal(int newGoal) {
    _dailyGoal = newGoal;
    _scheduleWaterReminders();
    notifyListeners();
  }

  Future<void> _scheduleWaterReminders() async {
    if (_notifPrefs == null) return;

    final enabled =
        _notifPrefs!.notificationsEnabled &&
        _notifPrefs!.waterNotificationsEnabled;
    final interval = _notifPrefs!.waterReminderIntervalHours;

    await _notificationService.scheduleWaterReminders(
      enabled: enabled,
      intervalHours: interval,
      currentIntake: _totalIntake,
      dailyGoal: _dailyGoal,
    );
  }
}
