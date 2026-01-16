class HabitModel {
  final int? id;
  final String name;
  final String description;
  final String frequency;
  final DateTime createdDate;
  final String category;

  HabitModel({
    this.id,
    required this.name,
    this.description = '',
    this.frequency = 'Daily',
    DateTime? createdDate,
    this.category = 'General',
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'createdDate': createdDate.toIso8601String(),
      'category': category,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      createdDate: DateTime.parse(map['createdDate'] as String),
      category: map['category'] as String? ?? 'General',
    );
  }

  HabitModel copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    DateTime? createdDate,
    String? category,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      createdDate: createdDate ?? this.createdDate,
      category: category ?? this.category,
    );
  }
}

class HabitLogModel {
  final int? id;
  final int habitId;
  final DateTime completedDate;

  HabitLogModel({this.id, required this.habitId, DateTime? completedDate})
    : completedDate = completedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completedDate': completedDate.toIso8601String(),
    };
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      id: map['id'] as int?,
      habitId: map['habitId'] as int,
      completedDate: DateTime.parse(map['completedDate'] as String),
    );
  }
}
