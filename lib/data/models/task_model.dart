class TaskModel {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdDate;
  final String category;
  final int priority; // 0 = low, 1 = medium, 2 = high

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdDate,
    this.category = 'General',
    this.priority = 0,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'category': category,
      'priority': priority,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isCompleted: (map['isCompleted'] as int) == 1,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'] as String)
          : null,
      createdDate: DateTime.parse(map['createdDate'] as String),
      category: map['category'] as String? ?? 'General',
      priority: map['priority'] as int? ?? 0,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedDate,
    DateTime? createdDate,
    String? category,
    int? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      createdDate: createdDate ?? this.createdDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}
