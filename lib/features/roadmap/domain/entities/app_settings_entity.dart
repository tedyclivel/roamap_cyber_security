// lib/features/roadmap/domain/entities/app_settings_entity.dart

enum ThemeVariant { emerald, cyan, amber, rose }

class AppSettingsEntity {
  final String agentId;
  final bool notificationsEnabled;
  final int notificationHour;
  final ThemeVariant? _themeVariant;

  ThemeVariant get themeVariant => _themeVariant ?? ThemeVariant.emerald;

  AppSettingsEntity({
    required this.agentId,
    required this.notificationsEnabled,
    required this.notificationHour,
    ThemeVariant? themeVariant = ThemeVariant.emerald,
  }) : _themeVariant = themeVariant;

  AppSettingsEntity copyWith({
    String? agentId,
    bool? notificationsEnabled,
    int? notificationHour,
    ThemeVariant? themeVariant,
  }) {
    return AppSettingsEntity(
      agentId: agentId ?? this.agentId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      themeVariant: themeVariant ?? this.themeVariant,
    );
  }
}
