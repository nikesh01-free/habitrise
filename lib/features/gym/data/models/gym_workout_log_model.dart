class GymWorkoutLogModel {
  final String id;
  final String? scheduleId; // Links back to a template if used
  final String completedDate; // Format: yyyy-MM-dd
  final List<String> actualMuscleGroups;
  final int durationMinutes;
  final String intensity; // easy, medium, hard
  final String moodAfter; // good, neutral, exhausted
  final String notes;
  final DateTime createdAt;

  GymWorkoutLogModel({
    required this.id,
    this.scheduleId,
    required this.completedDate,
    required this.actualMuscleGroups,
    this.durationMinutes = 0,
    required this.intensity,
    required this.moodAfter,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'completedDate': completedDate,
      'actualMuscleGroups': actualMuscleGroups,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'moodAfter': moodAfter,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GymWorkoutLogModel.fromMap(Map<String, dynamic> map) {
    return GymWorkoutLogModel(
      id: map['id'] as String? ?? '',
      scheduleId: map['scheduleId'] as String?,
      completedDate: map['completedDate'] as String? ?? '',
      actualMuscleGroups: List<String>.from(map['actualMuscleGroups'] ?? []),
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      intensity: map['intensity'] as String? ?? 'medium',
      moodAfter: map['moodAfter'] as String? ?? 'neutral',
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
