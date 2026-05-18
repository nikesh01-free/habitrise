class MoodLogModel {
  final String id;
  final String logDate; // YYYY-MM-DD
  final String mood; // great, good, okay, bad, tired
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodLogModel({
    required this.id,
    required this.logDate,
    required this.mood,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  MoodLogModel copyWith({
    String? id,
    String? logDate,
    String? mood,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'log_date': logDate,
      'mood': mood,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MoodLogModel.fromMap(Map<String, dynamic> map) {
    return MoodLogModel(
      id: map['id'] as String,
      logDate: map['log_date'] as String,
      mood: map['mood'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
