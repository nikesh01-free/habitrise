class ProfileModel {
  final String id;
  final String displayName;
  final String ageGroup;
  final String userType;
  final int dailyStepGoal;
  final int dailyWaterGoalMl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.displayName,
    required this.ageGroup,
    required this.userType,
    this.dailyStepGoal = 8000,
    this.dailyWaterGoalMl = 2500,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileModel copyWith({
    String? id,
    String? displayName,
    String? ageGroup,
    String? userType,
    int? dailyStepGoal,
    int? dailyWaterGoalMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      ageGroup: ageGroup ?? this.ageGroup,
      userType: userType ?? this.userType,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'ageGroup': ageGroup,
      'userType': userType,
      'dailyStepGoal': dailyStepGoal,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      ageGroup: map['ageGroup'] ?? '',
      userType: map['userType'] ?? 'wellness',
      dailyStepGoal: map['dailyStepGoal'] ?? 8000,
      dailyWaterGoalMl: map['dailyWaterGoalMl'] ?? 2500,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
