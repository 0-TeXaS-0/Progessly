import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs for different categories
  static const int waterReminderId = 100;
  static const int taskMorningReminderId = 200;
  static const int taskEveningReminderId = 201;
  static const int mealBreakfastReminderId = 300;
  static const int mealLunchReminderId = 301;
  static const int mealDinnerReminderId = 302;
  static const int streakReminderId = 400;
  static const int habitReminderIdStart = 1000; // Habits start from 1000+

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('✅ Notification Service initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - can navigate to specific screens
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'progressly_channel',
      'Progressly Notifications',
      channelDescription: 'Notifications for tasks, habits, water, and meals',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progressly_channel',
          'Progressly Notifications',
          channelDescription:
              'Notifications for tasks, habits, water, and meals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // Schedule repeating notification at intervals
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required Duration interval,
    String? payload,
  }) async {
    // For water reminders - schedule multiple daily notifications
    if (interval.inHours >= 1 && interval.inHours <= 4) {
      await cancelNotification(id);

      // Schedule from 8 AM to 10 PM
      const startHour = 8;
      const endHour = 22;
      final intervalHours = interval.inHours;

      int notificationId = id;
      for (int hour = startHour; hour < endHour; hour += intervalHours) {
        await scheduleDailyNotification(
          id: notificationId++,
          title: title,
          body: body,
          hour: hour,
          minute: 0,
          payload: payload,
        );
      }
    }
  }

  // Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Water reminders
  Future<void> scheduleWaterReminders({
    required bool enabled,
    required int intervalHours,
    int currentIntake = 0,
    int dailyGoal = 2000,
  }) async {
    if (!enabled) {
      await cancelWaterReminders();
      return;
    }

    final remaining = dailyGoal - currentIntake;
    String body = remaining > 0
        ? 'Time to hydrate! ${currentIntake}ml / ${dailyGoal}ml today 💧'
        : 'Great job! Daily goal achieved! 🎉';

    await scheduleRepeatingNotification(
      id: waterReminderId,
      title: '💧 Water Reminder',
      body: body,
      interval: Duration(hours: intervalHours),
      payload: 'water',
    );
  }

  Future<void> cancelWaterReminders() async {
    // Cancel all water reminder variants (8 AM to 10 PM every 2 hours = 7 notifications)
    for (int i = 0; i < 10; i++) {
      await cancelNotification(waterReminderId + i);
    }
  }

  // Task reminders
  Future<void> scheduleTaskReminders({
    required bool enabled,
    required int pendingTasks,
  }) async {
    if (!enabled) {
      await cancelTaskReminders();
      return;
    }

    // Morning reminder (9 AM)
    await scheduleDailyNotification(
      id: taskMorningReminderId,
      title: '✅ Good Morning!',
      body: pendingTasks > 0
          ? 'You have $pendingTasks task${pendingTasks > 1 ? 's' : ''} pending today'
          : 'No tasks for today. Have a great day!',
      hour: 9,
      minute: 0,
      payload: 'tasks',
    );

    // Evening reminder (6 PM)
    if (pendingTasks > 0) {
      await scheduleDailyNotification(
        id: taskEveningReminderId,
        title: '✅ Task Reminder',
        body: 'Complete your tasks before the day ends!',
        hour: 18,
        minute: 0,
        payload: 'tasks',
      );
    }
  }

  Future<void> cancelTaskReminders() async {
    await cancelNotification(taskMorningReminderId);
    await cancelNotification(taskEveningReminderId);
  }

  // Meal reminders
  Future<void> scheduleMealReminders({required bool enabled}) async {
    if (!enabled) {
      await cancelMealReminders();
      return;
    }

    // Breakfast (8 AM)
    await scheduleDailyNotification(
      id: mealBreakfastReminderId,
      title: '🍳 Breakfast Time',
      body: 'Don\'t forget to log your breakfast!',
      hour: 8,
      minute: 0,
      payload: 'meal_breakfast',
    );

    // Lunch (1 PM)
    await scheduleDailyNotification(
      id: mealLunchReminderId,
      title: '🍽️ Lunch Time',
      body: 'Don\'t forget to log your lunch!',
      hour: 13,
      minute: 0,
      payload: 'meal_lunch',
    );

    // Dinner (7 PM)
    await scheduleDailyNotification(
      id: mealDinnerReminderId,
      title: '🍕 Dinner Time',
      body: 'Don\'t forget to log your dinner!',
      hour: 19,
      minute: 0,
      payload: 'meal_dinner',
    );
  }

  Future<void> cancelMealReminders() async {
    await cancelNotification(mealBreakfastReminderId);
    await cancelNotification(mealLunchReminderId);
    await cancelNotification(mealDinnerReminderId);
  }

  // Habit reminders
  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required bool enabled,
    int hour = 9,
    int minute = 0,
  }) async {
    final notificationId = habitReminderIdStart + habitId;

    if (!enabled) {
      await cancelNotification(notificationId);
      return;
    }

    await scheduleDailyNotification(
      id: notificationId,
      title: '🎯 Habit Reminder',
      body: 'Time to $habitName! Keep your streak going! 🔥',
      hour: hour,
      minute: minute,
      payload: 'habit_$habitId',
    );
  }

  // Streak motivation
  Future<void> scheduleStreakReminder({
    required bool enabled,
    required int currentStreak,
    required bool hasCompletedToday,
  }) async {
    if (!enabled || hasCompletedToday) {
      await cancelNotification(streakReminderId);
      return;
    }

    String body = currentStreak > 0
        ? 'Don\'t break your $currentStreak-day streak! Complete your habits today 🔥'
        : 'Start your streak today! Complete at least one activity 💪';

    await scheduleDailyNotification(
      id: streakReminderId,
      title: '🔥 Streak Reminder',
      body: body,
      hour: 20,
      minute: 0,
      payload: 'streak',
    );
  }

  // Milestone celebration
  Future<void> showMilestoneNotification({
    required String title,
    required int streak,
  }) async {
    await showNotification(
      id: 9999,
      title: '🎉 Milestone Achieved!',
      body: '$title - $streak day streak! Keep it up!',
      payload: 'milestone',
    );
  }
}
