class SleepLogModel {
  final String id;
  final String sleepDate; // Reference morning date YYYY-MM-DD
  final DateTime sleepTime;
  final DateTime wakeTime;
  final int totalMinutes;
  final String quality; // poor, okay, good, excellent
  final DateTime createdAt;
  final DateTime updatedAt;

  const SleepLogModel({
    required this.id,
    required this.sleepDate,
    required this.sleepTime,
    required this.wakeTime,
    required this.totalMinutes,
    required this.quality,
    required this.createdAt,
    required this.updatedAt,
  });

  SleepLogModel copyWith({
    String? id,
    String? sleepDate,
    DateTime? sleepTime,
    DateTime? wakeTime,
    int? totalMinutes,
    String? quality,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepLogModel(
      id: id ?? this.id,
      sleepDate: sleepDate ?? this.sleepDate,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      quality: quality ?? this.quality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sleepDate': sleepDate,
      'sleepTime': sleepTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'totalMinutes': totalMinutes,
      'quality': quality,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SleepLogModel.fromMap(Map<String, dynamic> map) {
    return SleepLogModel(
      id: map['id'] ?? '',
      sleepDate: map['sleepDate'] ?? '',
      sleepTime: DateTime.parse(map['sleepTime']),
      wakeTime: DateTime.parse(map['wakeTime']),
      totalMinutes: map['totalMinutes'] ?? 0,
      quality: map['quality'] ?? 'okay',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
