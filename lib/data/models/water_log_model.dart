class WaterLogModel {
  final int? id;
  final int amount;
  final DateTime loggedDate;
  final String time;

  WaterLogModel({
    this.id,
    required this.amount,
    DateTime? loggedDate,
    this.time = '',
  }) : loggedDate = loggedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'loggedDate': loggedDate.toIso8601String(),
      'time': time,
    };
  }

  factory WaterLogModel.fromMap(Map<String, dynamic> map) {
    return WaterLogModel(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      loggedDate: DateTime.parse(map['loggedDate'] as String),
      time: map['time'] as String? ?? '',
    );
  }

  WaterLogModel copyWith({
    int? id,
    int? amount,
    DateTime? loggedDate,
    String? time,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      loggedDate: loggedDate ?? this.loggedDate,
      time: time ?? this.time,
    );
  }
}
