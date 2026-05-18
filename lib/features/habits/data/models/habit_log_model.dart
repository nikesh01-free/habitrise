class HabitLogModel {
  final String id;
  final String habitId;
  final String logDate; // YYYY-MM-DD
  final String status; // completed, missed, skipped
  final double? completedValue;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.logDate,
    required this.status,
    this.completedValue,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  HabitLogModel copyWith({
    String? id,
    String? habitId,
    String? logDate,
    String? status,
    double? completedValue,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      logDate: logDate ?? this.logDate,
      status: status ?? this.status,
      completedValue: completedValue ?? this.completedValue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'habit_id': habitId,
      'log_date': logDate,
      'status': status,
      'completed_value': completedValue,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      logDate: map['log_date'] as String,
      status: map['status'] as String,
      completedValue: (map['completed_value'] as num?)?.toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
