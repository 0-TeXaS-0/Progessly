class UserProfile {
  final String name;
  final int age;
  final String gender;
  final int weight;
  final bool notificationsEnabled;
  final String email;
  final double height;
  final String goal;
  final String avatarPath;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    this.notificationsEnabled = true,
    this.email = '',
    this.height = 0,
    this.goal = '',
    this.avatarPath = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'notificationsEnabled': notificationsEnabled,
      'email': email,
      'height': height,
      'goal': goal,
      'avatarPath': avatarPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      weight: json['weight'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      email: json['email'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 0,
      goal: json['goal'] as String? ?? '',
      avatarPath: json['avatarPath'] as String? ?? '',
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    int? weight,
    bool? notificationsEnabled,
    String? email,
    double? height,
    String? goal,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      email: email ?? this.email,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
