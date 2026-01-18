class MealTemplateModel {
  final int? id;
  final String name;
  final int calories;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final bool isFavorite;
  final int timesLogged;
  final DateTime createdAt;

  MealTemplateModel({
    this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    this.isFavorite = true,
    this.timesLogged = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'mealType': mealType,
      'isFavorite': isFavorite ? 1 : 0,
      'timesLogged': timesLogged,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealTemplateModel.fromMap(Map<String, dynamic> map) {
    return MealTemplateModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: map['calories'] as int,
      mealType: map['mealType'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
      timesLogged: map['timesLogged'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  MealTemplateModel copyWith({
    int? id,
    String? name,
    int? calories,
    String? mealType,
    bool? isFavorite,
    int? timesLogged,
    DateTime? createdAt,
  }) {
    return MealTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      isFavorite: isFavorite ?? this.isFavorite,
      timesLogged: timesLogged ?? this.timesLogged,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
