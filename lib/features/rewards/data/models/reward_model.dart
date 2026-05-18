class RewardModel {
  final String id;
  final String title;
  final String description;
  final String rewardType; // badge, theme, streak, frame
  final String unlockCondition;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardType,
    required this.unlockCondition,
    this.unlockedAt,
    this.isUnlocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? rewardType,
    String? unlockCondition,
    DateTime? unlockedAt,
    bool? isUnlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'reward_type': rewardType,
      'unlock_condition': unlockCondition,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'is_unlocked': isUnlocked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      rewardType: map['reward_type'] as String,
      unlockCondition: map['unlock_condition'] as String,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      isUnlocked: map['is_unlocked'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
