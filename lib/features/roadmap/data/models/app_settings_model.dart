// lib/features/roadmap/data/models/app_settings_model.dart

import 'package:hive/hive.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 4)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  String? agentId;

  @HiveField(1)
  bool? notificationsEnabled;

  @HiveField(2)
  int? notificationHour;

  @HiveField(3)
  int? themeIndex;

  AppSettingsModel({
    this.agentId = 'AGENT_001',
    this.notificationsEnabled = true,
    this.notificationHour = 8,
    this.themeIndex = 0,
  });

  factory AppSettingsModel.fromEntity(AppSettingsEntity entity) {
    return AppSettingsModel(
      agentId:              entity.agentId,
      notificationsEnabled: entity.notificationsEnabled,
      notificationHour:     entity.notificationHour,
      themeIndex:           entity.themeVariant.index,
    );
  }

  AppSettingsEntity toEntity() {
    return AppSettingsEntity(
      agentId:              agentId              ?? 'AGENT_001',
      notificationsEnabled: notificationsEnabled ?? true,
      notificationHour:     notificationHour     ?? 8,
      themeVariant:         ThemeVariant.values[(themeIndex ?? 0).clamp(0, ThemeVariant.values.length - 1)],
    );
  }
}
