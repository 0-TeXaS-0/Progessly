class StreakData {
  final int dailyStreak;
  final int weeklyStreak;
  final int longestStreak;

  StreakData({
    this.dailyStreak = 0,
    this.weeklyStreak = 0,
    this.longestStreak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyStreak': dailyStreak,
      'weeklyStreak': weeklyStreak,
      'longestStreak': longestStreak,
    };
  }

  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      dailyStreak: map['dailyStreak'] as int? ?? 0,
      weeklyStreak: map['weeklyStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
    );
  }

  StreakData copyWith({
    int? dailyStreak,
    int? weeklyStreak,
    int? longestStreak,
  }) {
    return StreakData(
      dailyStreak: dailyStreak ?? this.dailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}

class DailySummary {
  final DateTime date;
  final int tasksCompleted;
  final int mealsLogged;
  final int waterIntake;
  final int habitsCompleted;
  final int totalCalories;

  DailySummary({
    DateTime? date,
    this.tasksCompleted = 0,
    this.mealsLogged = 0,
    this.waterIntake = 0,
    this.habitsCompleted = 0,
    this.totalCalories = 0,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'tasksCompleted': tasksCompleted,
      'mealsLogged': mealsLogged,
      'waterIntake': waterIntake,
      'habitsCompleted': habitsCompleted,
      'totalCalories': totalCalories,
    };
  }

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      date: DateTime.parse(map['date'] as String),
      tasksCompleted: map['tasksCompleted'] as int? ?? 0,
      mealsLogged: map['mealsLogged'] as int? ?? 0,
      waterIntake: map['waterIntake'] as int? ?? 0,
      habitsCompleted: map['habitsCompleted'] as int? ?? 0,
      totalCalories: map['totalCalories'] as int? ?? 0,
    );
  }
}
