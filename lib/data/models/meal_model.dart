class MealModel {
  final int? id;
  final String name;
  final int calories;
  final String mealType;
  final DateTime loggedDate;
  final String time;

  MealModel({
    this.id,
    required this.name,
    this.calories = 0,
    this.mealType = 'Breakfast',
    DateTime? loggedDate,
    this.time = '',
  }) : loggedDate = loggedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'mealType': mealType,
      'loggedDate': loggedDate.toIso8601String(),
      'time': time,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: map['calories'] as int? ?? 0,
      mealType: map['mealType'] as String? ?? 'Breakfast',
      loggedDate: DateTime.parse(map['loggedDate'] as String),
      time: map['time'] as String? ?? '',
    );
  }

  MealModel copyWith({
    int? id,
    String? name,
    int? calories,
    String? mealType,
    DateTime? loggedDate,
    String? time,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      loggedDate: loggedDate ?? this.loggedDate,
      time: time ?? this.time,
    );
  }
}
