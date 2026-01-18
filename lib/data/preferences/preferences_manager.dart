import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class PreferencesManager {
  static const String _keyName = 'user_name';
  static const String _keyAge = 'user_age';
  static const String _keyGender = 'user_gender';
  static const String _keyWeight = 'user_weight';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyDailyWaterGoal = 'daily_water_goal';
  static const String _keyAvatarPath = 'user_avatar_path';
  static const String _keyEmail = 'user_email';
  static const String _keyHeight = 'user_height';
  static const String _keyGoal = 'user_goal';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_keyOnboardingComplete, complete);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_keyName, profile.name);
    await _prefs.setInt(_keyAge, profile.age);
    await _prefs.setString(_keyGender, profile.gender);
    await _prefs.setInt(_keyWeight, profile.weight);
    await _prefs.setBool(_keyNotifications, profile.notificationsEnabled);
    await _prefs.setString(_keyEmail, profile.email);
    await _prefs.setDouble(_keyHeight, profile.height);
    await _prefs.setString(_keyGoal, profile.goal);
    await _prefs.setString(_keyAvatarPath, profile.avatarPath);
  }

  UserProfile? getUserProfile() {
    final name = _prefs.getString(_keyName);
    final age = _prefs.getInt(_keyAge);
    final gender = _prefs.getString(_keyGender);
    final weight = _prefs.getInt(_keyWeight);

    if (name == null || age == null || gender == null || weight == null) {
      return null;
    }

    return UserProfile(
      name: name,
      age: age,
      gender: gender,
      weight: weight,
      notificationsEnabled: _prefs.getBool(_keyNotifications) ?? true,
      email: _prefs.getString(_keyEmail) ?? '',
      height: _prefs.getDouble(_keyHeight) ?? 0,
      goal: _prefs.getString(_keyGoal) ?? '',
      avatarPath: _prefs.getString(_keyAvatarPath) ?? '',
    );
  }

  Future<void> updateUserName(String name) async {
    await _prefs.setString(_keyName, name);
  }

  Future<void> updateUserWeight(int weight) async {
    await _prefs.setInt(_keyWeight, weight);
  }

  // Water Goal
  Future<void> setDailyWaterGoal(int goal) async {
    await _prefs.setInt(_keyDailyWaterGoal, goal);
  }

  int getDailyWaterGoal() {
    return _prefs.getInt(_keyDailyWaterGoal) ?? 2000;
  }

  int calculateWaterGoal(int weight, String gender) {
    // Formula: weight * 35 ml, adjusted by gender
    int baseGoal = weight * 35;

    // Females: 5% lower
    if (gender.toLowerCase() == 'female') {
      baseGoal = (baseGoal * 0.95).round();
    }

    return baseGoal;
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool(_keyNotifications) ?? true;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
