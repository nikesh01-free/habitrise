class GymScheduleModel {
  final String id;
  final String dayOfWeek;
  final List<String> muscleGroups;
  final String workoutTitle;
  final String notes;
  final bool isRestDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.muscleGroups,
    required this.workoutTitle,
    this.notes = '',
    this.isRestDay = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'muscleGroups': muscleGroups,
      'workoutTitle': workoutTitle,
      'notes': notes,
      'isRestDay': isRestDay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GymScheduleModel.fromMap(Map<String, dynamic> map) {
    return GymScheduleModel(
      id: map['id'] as String? ?? '',
      dayOfWeek: map['dayOfWeek'] as String? ?? 'Monday',
      muscleGroups: List<String>.from(map['muscleGroups'] ?? []),
      workoutTitle: map['workoutTitle'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isRestDay: map['isRestDay'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  GymScheduleModel copyWith({
    String? dayOfWeek,
    List<String>? muscleGroups,
    String? workoutTitle,
    String? notes,
    bool? isRestDay,
    DateTime? updatedAt,
  }) {
    return GymScheduleModel(
      id: id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      notes: notes ?? this.notes,
      isRestDay: isRestDay ?? this.isRestDay,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
