import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/preferences/notification_preferences.dart';
import '../../services/notification_service.dart';
import '../../providers/water_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/habit_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _prefs;
  bool _isLoading = true;

  bool _notificationsEnabled = true;
  bool _waterEnabled = true;
  bool _tasksEnabled = true;
  bool _mealsEnabled = true;
  bool _habitsEnabled = true;
  bool _streakEnabled = true;
  int _waterInterval = 2;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = NotificationPreferences(prefs);

    setState(() {
      _notificationsEnabled = _prefs!.notificationsEnabled;
      _waterEnabled = _prefs!.waterNotificationsEnabled;
      _tasksEnabled = _prefs!.tasksNotificationsEnabled;
      _mealsEnabled = _prefs!.mealsNotificationsEnabled;
      _habitsEnabled = _prefs!.habitsNotificationsEnabled;
      _streakEnabled = _prefs!.streakNotificationsEnabled;
      _waterInterval = _prefs!.waterReminderIntervalHours;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings() async {
    if (_prefs == null) return;

    // Refresh all providers to update notifications
    if (mounted) {
      context.read<WaterProvider>().loadWaterLogs();
      context.read<TaskProvider>().loadTasks();
      context.read<MealProvider>().loadMeals();
      context.read<HabitProvider>().loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Master Toggle
          Card(
            child: SwitchListTile(
              title: const Text(
                'Enable Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text('Master switch for all notifications'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _prefs?.setNotificationsEnabled(value);

                if (value) {
                  await _notificationService.requestPermissions();
                } else {
                  await _notificationService.cancelAllNotifications();
                }

                await _updateSettings();
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Category Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Water Notifications
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('💧 Water Reminders'),
                  subtitle: const Text('Remind me to drink water'),
                  value: _waterEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          setState(() => _waterEnabled = value);
                          await _prefs?.setWaterNotificationsEnabled(value);
                          await _updateSettings();
                        }
                      : null,
                ),
                if (_waterEnabled && _notificationsEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reminder Frequency'),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 1, label: Text('1h')),
                            ButtonSegment(value: 2, label: Text('2h')),
                            ButtonSegment(value: 3, label: Text('3h')),
                            ButtonSegment(value: 4, label: Text('4h')),
                          ],
                          selected: {_waterInterval},
                          onSelectionChanged: (Set<int> selected) async {
                            setState(() => _waterInterval = selected.first);
                            await _prefs?.setWaterReminderIntervalHours(
                              selected.first,
                            );
                            await _updateSettings();
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Task Notifications
          Card(
            child: SwitchListTile(
              title: const Text('✅ Task Reminders'),
              subtitle: const Text('Morning and evening task reminders'),
              value: _tasksEnabled,
              onChanged: _notificationsEnabled
                  ? (value) async {
                      setState(() => _tasksEnabled = value);
                      await _prefs?.setTasksNotificationsEnabled(value);
                      await _updateSettings();
                    }
                  : null,
            ),
          ),

          // Meal Notifications
          Card(
            child: SwitchListTile(
              title: const Text('🍽️ Meal Reminders'),
              subtitle: const Text('Breakfast, lunch, and dinner reminders'),
              value: _mealsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) async {
                      setState(() => _mealsEnabled = value);
                      await _prefs?.setMealsNotificationsEnabled(value);
                      await _updateSettings();
                    }
                  : null,
            ),
          ),

          // Habit Notifications
          Card(
            child: SwitchListTile(
              title: const Text('🎯 Habit Reminders'),
              subtitle: const Text('Daily habit completion reminders'),
              value: _habitsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) async {
                      setState(() => _habitsEnabled = value);
                      await _prefs?.setHabitsNotificationsEnabled(value);
                      await _updateSettings();
                    }
                  : null,
            ),
          ),

          // Streak Notifications
          Card(
            child: SwitchListTile(
              title: const Text('🔥 Streak Reminders'),
              subtitle: const Text('Don\'t break your streak alerts'),
              value: _streakEnabled,
              onChanged: _notificationsEnabled
                  ? (value) async {
                      setState(() => _streakEnabled = value);
                      await _prefs?.setStreakNotificationsEnabled(value);
                      await _updateSettings();
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // Info card
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifications are scheduled between 8 AM and 10 PM to avoid disturbing your sleep.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Test notification button
          OutlinedButton.icon(
            onPressed: _notificationsEnabled
                ? () async {
                    await _notificationService.showNotification(
                      id: 99999,
                      title: '🎉 Test Notification',
                      body: 'Notifications are working perfectly!',
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Send Test Notification'),
          ),
        ],
      ),
    );
  }
}
