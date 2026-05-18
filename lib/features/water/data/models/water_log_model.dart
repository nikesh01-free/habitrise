class WaterLogModel {
  final String id;
  final String logDate; // YYYY-MM-DD
  final int amountMl;
  final DateTime entryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaterLogModel({
    required this.id,
    required this.logDate,
    required this.amountMl,
    required this.entryTime,
    required this.createdAt,
    required this.updatedAt,
  });

  WaterLogModel copyWith({
    String? id,
    String? logDate,
    int? amountMl,
    DateTime? entryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      amountMl: amountMl ?? this.amountMl,
      entryTime: entryTime ?? this.entryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'log_date': logDate,
      'amount_ml': amountMl,
      'entry_time': entryTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WaterLogModel.fromMap(Map<String, dynamic> map) {
    return WaterLogModel(
      id: map['id'] as String,
      logDate: map['log_date'] as String,
      amountMl: map['amount_ml'] as int,
      entryTime: DateTime.parse(map['entry_time'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
