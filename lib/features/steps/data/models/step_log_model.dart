class StepLogModel {
  final String id;
  final String logDate; // YYYY-MM-DD
  final int steps;
  final int goalSteps;
  final double? distanceKm;
  final double? calories;
  final String source; // pedometer, manual
  final DateTime createdAt;
  final DateTime updatedAt;

  const StepLogModel({
    required this.id,
    required this.logDate,
    required this.steps,
    this.goalSteps = 8000,
    this.distanceKm,
    this.calories,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  StepLogModel copyWith({
    String? id,
    String? logDate,
    int? steps,
    int? goalSteps,
    double? distanceKm,
    double? calories,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      steps: steps ?? this.steps,
      goalSteps: goalSteps ?? this.goalSteps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'log_date': logDate,
      'steps': steps,
      'goal_steps': goalSteps,
      'distance_km': distanceKm,
      'calories': calories,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StepLogModel.fromMap(Map<String, dynamic> map) {
    return StepLogModel(
      id: map['id'] as String,
      logDate: map['log_date'] as String,
      steps: map['steps'] as int,
      goalSteps: map['goal_steps'] as int? ?? 8000,
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
      calories: (map['calories'] as num?)?.toDouble(),
      source: map['source'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
