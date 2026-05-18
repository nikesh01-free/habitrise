class AppSettingsModel {
  final String id;
  final String themeMode; // light, dark, system
  final String accentColor;
  final bool notificationsEnabled;
  final bool stepTrackingEnabled;
  final bool reducedMotionEnabled;
  final bool gymFeatureEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppSettingsModel({
    required this.id,
    this.themeMode = 'system',
    required this.accentColor,
    this.notificationsEnabled = true,
    this.stepTrackingEnabled = false,
    this.reducedMotionEnabled = false,
    this.gymFeatureEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  AppSettingsModel copyWith({
    String? id,
    String? themeMode,
    String? accentColor,
    bool? notificationsEnabled,
    bool? stepTrackingEnabled,
    bool? reducedMotionEnabled,
    bool? gymFeatureEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettingsModel(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      stepTrackingEnabled: stepTrackingEnabled ?? this.stepTrackingEnabled,
      reducedMotionEnabled: reducedMotionEnabled ?? this.reducedMotionEnabled,
      gymFeatureEnabled: gymFeatureEnabled ?? this.gymFeatureEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'theme_mode': themeMode,
      'accent_color': accentColor,
      'notifications_enabled': notificationsEnabled,
      'step_tracking_enabled': stepTrackingEnabled,
      'reduced_motion_enabled': reducedMotionEnabled,
      'gym_feature_enabled': gymFeatureEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      id: map['id'] as String,
      themeMode: map['theme_mode'] as String? ?? 'system',
      accentColor: map['accent_color'] as String,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      stepTrackingEnabled: map['step_tracking_enabled'] as bool? ?? false,
      reducedMotionEnabled: map['reduced_motion_enabled'] as bool? ?? false,
      gymFeatureEnabled: map['gym_feature_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
