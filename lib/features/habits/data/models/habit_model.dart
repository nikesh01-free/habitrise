class HabitModel {
  final String id;
  final String title;
  final String category;
  final String type;
  final String frequency;
  final double? targetValue;
  final String? unit;
  final String? icon;
  final String colorHex;
  final bool reminderEnabled;
  final String? reminderTime;
  final bool isArchived;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.frequency,
    this.targetValue,
    this.unit,
    this.icon,
    required this.colorHex,
    this.reminderEnabled = false,
    this.reminderTime,
    this.isArchived = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    String? type,
    String? frequency,
    double? targetValue,
    String? unit,
    String? icon,
    String? colorHex,
    bool? reminderEnabled,
    String? reminderTime,
    bool? isArchived,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'type': type,
      'frequency': frequency,
      'target_value': targetValue,
      'unit': unit,
      'icon': icon,
      'color_hex': colorHex,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
      'is_archived': isArchived,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      type: map['type'] as String,
      frequency: map['frequency'] as String,
      targetValue: (map['target_value'] as num?)?.toDouble(),
      unit: map['unit'] as String?,
      icon: map['icon'] as String?,
      colorHex: map['color_hex'] as String,
      reminderEnabled: map['reminder_enabled'] as bool? ?? false,
      reminderTime: map['reminder_time'] as String?,
      isArchived: map['is_archived'] as bool? ?? false,
      isPinned: map['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
