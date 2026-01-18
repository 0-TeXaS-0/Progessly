import '../data/repositories/task_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/habit_repository.dart';

class InsightModel {
  final String title;
  final String message;
  final String icon;
  final InsightType type;
  final DateTime generatedAt;

  InsightModel({
    required this.title,
    required this.message,
    required this.icon,
    required this.type,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}

enum InsightType { productivity, health, motivation, warning, achievement }

class InsightsService {
  final TaskRepository _taskRepo = TaskRepository();
  final MealRepository _mealRepo = MealRepository();
  final WaterRepository _waterRepo = WaterRepository();
  final HabitRepository _habitRepo = HabitRepository();

  Future<List<InsightModel>> generateInsights({
    int dailyWaterGoal = 2000,
  }) async {
    final insights = <InsightModel>[];
    final now = DateTime.now();

    try {
      // Analyze last 7 days
      final last7Days = List.generate(
        7,
        (i) => now.subtract(Duration(days: i)),
      );

      // Task insights
      final taskInsights = await _analyzeTaskPatterns(last7Days);
      insights.addAll(taskInsights);

      // Water insights
      final waterInsights = await _analyzeWaterPatterns(
        last7Days,
        dailyWaterGoal,
      );
      insights.addAll(waterInsights);

      // Meal insights
      final mealInsights = await _analyzeMealPatterns(last7Days);
      insights.addAll(mealInsights);

      // Habit insights
      final habitInsights = await _analyzeHabitPatterns(last7Days);
      insights.addAll(habitInsights);

      // Streak insights
      final streakInsights = await _analyzeStreaks();
      insights.addAll(streakInsights);

      // Sort by importance (achievements first, then warnings)
      insights.sort((a, b) {
        final typeOrder = {
          InsightType.achievement: 0,
          InsightType.motivation: 1,
          InsightType.productivity: 2,
          InsightType.health: 3,
          InsightType.warning: 4,
        };
        return (typeOrder[a.type] ?? 5).compareTo(typeOrder[b.type] ?? 5);
      });

      return insights.take(5).toList(); // Return top 5 insights
    } catch (e) {
      return [];
    }
  }

  Future<List<InsightModel>> _analyzeTaskPatterns(List<DateTime> days) async {
    final insights = <InsightModel>[];

    try {
      final taskCounts = <int>[];
      final dayNames = <String>[];

      for (var day in days) {
        final count = await _taskRepo.getCompletedCount(day);
        taskCounts.add(count);
        dayNames.add(_getDayName(day.weekday));
      }

      if (taskCounts.isEmpty) return insights;

      // Find best performing day
      final maxTasks = taskCounts.reduce((a, b) => a > b ? a : b);
      if (maxTasks >= 5) {
        final bestDayIndex = taskCounts.indexOf(maxTasks);
        insights.add(
          InsightModel(
            title: 'Productivity Peak',
            message:
                'You\'re most productive on ${dayNames[bestDayIndex]}s! You completed $maxTasks tasks.',
            icon: '🚀',
            type: InsightType.productivity,
          ),
        );
      }

      // Check for consistency
      final avgTasks = taskCounts.reduce((a, b) => a + b) / taskCounts.length;
      if (avgTasks >= 3 && taskCounts.every((count) => count >= 2)) {
        insights.add(
          InsightModel(
            title: 'Consistent Performance',
            message:
                'You\'re maintaining steady productivity with ${avgTasks.toStringAsFixed(1)} tasks daily!',
            icon: '📊',
            type: InsightType.motivation,
          ),
        );
      }

      // Weekend vs weekday
      final weekdayTasks = taskCounts.take(5).toList();
      final weekendTasks = taskCounts.skip(5).toList();
      if (weekdayTasks.isNotEmpty && weekendTasks.isNotEmpty) {
        final weekdayAvg =
            weekdayTasks.reduce((a, b) => a + b) / weekdayTasks.length;
        final weekendAvg =
            weekendTasks.reduce((a, b) => a + b) / weekendTasks.length;

        if (weekendAvg < weekdayAvg * 0.5) {
          insights.add(
            InsightModel(
              title: 'Weekend Slowdown',
              message:
                  'Your task completion drops on weekends. Consider lighter goals!',
              icon: '🏖️',
              type: InsightType.productivity,
            ),
          );
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return insights;
  }

  Future<List<InsightModel>> _analyzeWaterPatterns(
    List<DateTime> days,
    int goal,
  ) async {
    final insights = <InsightModel>[];

    try {
      final waterIntakes = <int>[];
      for (var day in days) {
        final intake = await _waterRepo.getTotalIntake(day);
        waterIntakes.add(intake);
      }

      final goalsMetCount = waterIntakes
          .where((intake) => intake >= goal)
          .length;

      if (goalsMetCount >= 5) {
        insights.add(
          InsightModel(
            title: 'Hydration Champion',
            message:
                'You\'ve met your water goal $goalsMetCount days this week! Keep it up! 💧',
            icon: '💪',
            type: InsightType.achievement,
          ),
        );
      } else if (goalsMetCount <= 2) {
        insights.add(
          InsightModel(
            title: 'Hydration Alert',
            message:
                'You\'re only meeting your water goal $goalsMetCount days a week. Stay hydrated!',
            icon: '💧',
            type: InsightType.warning,
          ),
        );
      }

      // Check consistency
      final avgIntake =
          waterIntakes.reduce((a, b) => a + b) / waterIntakes.length;
      if (avgIntake >= goal * 0.9) {
        insights.add(
          InsightModel(
            title: 'Almost There!',
            message:
                'You\'re averaging ${avgIntake.toInt()}ml daily. Just ${(goal - avgIntake).toInt()}ml more to goal!',
            icon: '🎯',
            type: InsightType.motivation,
          ),
        );
      }
    } catch (e) {
      // Ignore errors
    }

    return insights;
  }

  Future<List<InsightModel>> _analyzeMealPatterns(List<DateTime> days) async {
    final insights = <InsightModel>[];

    try {
      final mealCounts = <int>[];
      for (var day in days) {
        final meals = await _mealRepo.getMealsByDate(day);
        mealCounts.add(meals.length);
      }

      final avgMeals = mealCounts.reduce((a, b) => a + b) / mealCounts.length;

      if (avgMeals >= 3.0) {
        insights.add(
          InsightModel(
            title: 'Meal Tracking Pro',
            message:
                'You\'re logging ${avgMeals.toStringAsFixed(1)} meals daily. Great job tracking your nutrition!',
            icon: '🍽️',
            type: InsightType.health,
          ),
        );
      }

      // Check for skipped days
      final skippedDays = mealCounts.where((count) => count == 0).length;
      if (skippedDays >= 3) {
        insights.add(
          InsightModel(
            title: 'Meal Tracking Reminder',
            message: 'You missed logging meals on $skippedDays days this week.',
            icon: '📝',
            type: InsightType.warning,
          ),
        );
      }
    } catch (e) {
      // Ignore errors
    }

    return insights;
  }

  Future<List<InsightModel>> _analyzeHabitPatterns(List<DateTime> days) async {
    final insights = <InsightModel>[];

    try {
      final habitCounts = <int>[];
      for (var day in days) {
        final count = await _habitRepo.getCompletedCount(day);
        habitCounts.add(count);
      }

      final perfectDays = habitCounts.where((count) => count >= 3).length;

      if (perfectDays >= 5) {
        insights.add(
          InsightModel(
            title: 'Habit Master',
            message: 'You had $perfectDays perfect habit days this week! 🔥',
            icon: '⭐',
            type: InsightType.achievement,
          ),
        );
      }
    } catch (e) {
      // Ignore errors
    }

    return insights;
  }

  Future<List<InsightModel>> _analyzeStreaks() async {
    final insights = <InsightModel>[];

    try {
      final taskStreak = await _taskRepo.calculateStreak();
      final mealStreak = await _mealRepo.calculateStreak();
      final waterStreak = await _waterRepo.calculateStreak(2000);

      final maxStreak = [
        taskStreak.dailyStreak,
        mealStreak.dailyStreak,
        waterStreak.dailyStreak,
      ].reduce((a, b) => a > b ? a : b);

      if (maxStreak >= 7) {
        insights.add(
          InsightModel(
            title: 'Streak Legend!',
            message: 'You have a $maxStreak day streak! You\'re on fire! 🔥',
            icon: '🔥',
            type: InsightType.achievement,
          ),
        );
      } else if (maxStreak >= 3) {
        insights.add(
          InsightModel(
            title: 'Building Momentum',
            message: 'You\'re on a $maxStreak day streak. Keep going!',
            icon: '💪',
            type: InsightType.motivation,
          ),
        );
      }
    } catch (e) {
      // Ignore errors
    }

    return insights;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
