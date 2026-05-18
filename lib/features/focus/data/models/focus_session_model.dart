class FocusSessionModel {
  final String id;
  final String category; // study, coding, reading, custom
  final int plannedMinutes;
  final int completedMinutes;
  final String status; // completed, cancelled, partial
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FocusSessionModel({
    required this.id,
    required this.category,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  FocusSessionModel copyWith({
    String? id,
    String? category,
    int? plannedMinutes,
    int? completedMinutes,
    String? status,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      category: category ?? this.category,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'planned_minutes': plannedMinutes,
      'completed_minutes': completedMinutes,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as String,
      category: map['category'] as String,
      plannedMinutes: map['planned_minutes'] as int,
      completedMinutes: map['completed_minutes'] as int,
      status: map['status'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
