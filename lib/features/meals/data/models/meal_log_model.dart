class MealLogModel {
  final String id;
  final String logDate; // YYYY-MM-DD
  final String mealName;
  final String mealType; // breakfast, lunch, dinner, snack, custom
  final String status; // completed, skipped, delayed
  final String? plannedTime; // HH:mm
  final DateTime? completedTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealLogModel({
    required this.id,
    required this.logDate,
    required this.mealName,
    required this.mealType,
    required this.status,
    this.plannedTime,
    this.completedTime,
    required this.createdAt,
    required this.updatedAt,
  });

  MealLogModel copyWith({
    String? id,
    String? logDate,
    String? mealName,
    String? mealType,
    String? status,
    String? plannedTime,
    DateTime? completedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      mealName: mealName ?? this.mealName,
      mealType: mealType ?? this.mealType,
      status: status ?? this.status,
      plannedTime: plannedTime ?? this.plannedTime,
      completedTime: completedTime ?? this.completedTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logDate': logDate,
      'mealName': mealName,
      'mealType': mealType,
      'status': status,
      'plannedTime': plannedTime,
      'completedTime': completedTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MealLogModel.fromMap(Map<String, dynamic> map) {
    return MealLogModel(
      id: map['id'] ?? '',
      logDate: map['logDate'] ?? '',
      mealName: map['mealName'] ?? '',
      mealType: map['mealType'] ?? 'custom',
      status: map['status'] ?? 'completed',
      plannedTime: map['plannedTime'],
      completedTime: map['completedTime'] != null
          ? DateTime.parse(map['completedTime'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
