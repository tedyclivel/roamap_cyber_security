// lib/core/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iron_mind/features/roadmap/data/models/task_model.dart';
import 'package:iron_mind/features/roadmap/data/models/roadmap_day_model.dart';
import 'package:iron_mind/features/roadmap/data/models/user_progress_model.dart';
import 'package:iron_mind/features/roadmap/data/models/app_settings_model.dart';

class HiveService {
  static const _taskBox        = 'tasks';
  static const _dayBox         = 'days';
  static const _progressBox    = 'progress';
  static const _settingsBox    = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(RoadmapDayModelAdapter());
    Hive.registerAdapter(UserProgressModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());
    await Hive.openBox<TaskModel>(_taskBox);
    await Hive.openBox<RoadmapDayModel>(_dayBox);
    await Hive.openBox<UserProgressModel>(_progressBox);
    await Hive.openBox<AppSettingsModel>(_settingsBox);
  }

  static Box<TaskModel>        get tasks    => Hive.box<TaskModel>(_taskBox);
  static Box<RoadmapDayModel>  get days     => Hive.box<RoadmapDayModel>(_dayBox);
  static Box<UserProgressModel>get progress => Hive.box<UserProgressModel>(_progressBox);
  static Box<AppSettingsModel> get settings => Hive.box<AppSettingsModel>(_settingsBox);
}
