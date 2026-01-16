class UserProfile {
  final String name;
  final int age;
  final String gender;
  final int weight;
  final bool notificationsEnabled;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      weight: json['weight'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    int? weight,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
