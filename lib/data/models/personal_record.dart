class PersonalRecord {
  final String id;
  final String category; // 'task', 'water', 'meal', 'habit'
  final String title;
  final double value;
  final String unit;
  final DateTime achievedDate;
  final String? description;

  PersonalRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.unit,
    required this.achievedDate,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'value': value,
    'unit': unit,
    'achievedDate': achievedDate.toIso8601String(),
    'description': description,
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
    id: json['id'],
    category: json['category'],
    title: json['title'],
    value: json['value'],
    unit: json['unit'],
    achievedDate: DateTime.parse(json['achievedDate']),
    description: json['description'],
  );

  PersonalRecord copyWith({
    String? id,
    String? category,
    String? title,
    double? value,
    String? unit,
    DateTime? achievedDate,
    String? description,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      achievedDate: achievedDate ?? this.achievedDate,
      description: description ?? this.description,
    );
  }
}
