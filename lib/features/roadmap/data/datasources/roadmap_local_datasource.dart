// lib/features/roadmap/data/datasources/roadmap_local_datasource.dart
import 'package:hive/hive.dart';
import 'package:iron_mind/core/services/hive_service.dart';
import 'package:iron_mind/features/roadmap/data/models/task_model.dart';
import 'package:iron_mind/features/roadmap/data/models/roadmap_day_model.dart';
import 'package:iron_mind/features/roadmap/data/models/user_progress_model.dart';
import 'package:iron_mind/features/roadmap/data/models/app_settings_model.dart';
import 'package:iron_mind/features/roadmap/data/seeds/roadmap_seed.dart';

class RoadmapLocalDataSource {
  Box<TaskModel>         get _tasks    => HiveService.tasks;
  Box<RoadmapDayModel>   get _days     => HiveService.days;
  Box<UserProgressModel> get _progress => HiveService.progress;

  // ── Jours ─────────────────────────────────────────────────────────
  RoadmapDayModel? getDay(int dayNumber) => _days.get(dayNumber);

  List<RoadmapDayModel> getAllDays() => _days.values.toList()
    ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

  Future<void> saveDay(RoadmapDayModel model) async {
    await _days.put(model.dayNumber, model);
  }

  // ── Tâches ────────────────────────────────────────────────────────
  List<TaskModel> getTasksForDay(int dayNumber) =>
      _tasks.values.where((t) => t.dayNumber == dayNumber).toList();

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    final tasks = _tasks.values.where((t) => t.id == taskId);
    if (tasks.isEmpty) return;
    final task = tasks.first;
    task.isCompleted = isCompleted;
    await _tasks.put(task.id, task);
  }

  Future<void> addTask(TaskModel task) async {
    await _tasks.put(task.id, task);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final Map<String, TaskModel> map = {for (var t in tasks) t.id: t};
    await _tasks.putAll(map);
  }

  // ── Progression ───────────────────────────────────────────────────
  UserProgressModel? getUserProgress() => _progress.get('main');

  Future<void> saveUserProgress(UserProgressModel model) async {
    await _progress.put('main', model);
  }

  // ── Initialisation ────────────────────────────────────────────────
  bool isInitialized() => _progress.isNotEmpty;

  Future<void> initializeRoadmap(DateTime startDate) async {
    // Progression initiale
    final prog = UserProgressModel(
      currentDay:                  1,
      totalPoints:                 0,
      currentStreak:               0,
      maxStreak:                   0,
      level:                       1,
      completedCodeforcesProblems: 0,
      completedCtfMachines:        0,
      completedCyberLabs:          0,
      completedContests:           0,
      pompesPR:                    0,
      gainagePR:                   0,
      totalDeepWorkMinutes:        0,
      startDate:                   startDate,
      unlockedBadgeIds:            [],
    );
    await _progress.put('main', prog);

    // 120 jours + tâches
    final seed = RoadmapSeed.generate(startDate);
    final taskMap = <String, TaskModel>{};
    final dayMap  = <int, RoadmapDayModel>{};

    for (final item in seed) {
      final day   = item['day']   as RoadmapDayModel;
      final tasks = item['tasks'] as List<TaskModel>;
      dayMap[day.dayNumber] = day;
      for (final t in tasks) taskMap[t.id] = t;
    }
    await _days.putAll(dayMap);
    await _tasks.putAll(taskMap);
  }

  // ── Journal ───────────────────────────────────────────────────────
  Future<void> saveJournalNote(int dayNumber, String note) async {
    final day = _days.get(dayNumber);
    if (day != null) {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      if (day.journalNote != null && day.journalNote!.trim().isNotEmpty) {
        day.journalNote = '${day.journalNote}\n\n[$timeStr] $note';
      } else {
        day.journalNote = '[$timeStr] $note';
      }
      await day.save();
    }
  }

  // ── Paramètres ───────────────────────────────────────────────────
  Box<AppSettingsModel> get _settings => HiveService.settings;

  AppSettingsModel getAppSettings() {
    return _settings.get('main') ?? AppSettingsModel(
      agentId: 'AGENT_001',
      notificationsEnabled: true,
      notificationHour: 8,
    );
  }

  Future<void> saveAppSettings(AppSettingsModel model) async {
    await _settings.put('main', model);
  }

  // ── Danger Zone / Soft Reset ──────────────────────────────────────
  Future<void> clearAllData() async {
    final startDate = DateTime.now();
    
    // 1. Reset de la progression au Jour 1
    final prog = UserProgressModel(
      currentDay:                  1,
      totalPoints:                 0,
      currentStreak:               0,
      maxStreak:                   0,
      level:                       1,
      completedCodeforcesProblems: 0,
      completedCtfMachines:        0,
      completedCyberLabs:          0,
      completedContests:           0,
      pompesPR:                    0,
      gainagePR:                   0,
      totalDeepWorkMinutes:        0,
      startDate:                   startDate,
      unlockedBadgeIds:            [],
    );
    await _progress.put('main', prog);

    // 2. Régénération stricte des jours et des tâches
    final seed = RoadmapSeed.generate(startDate);
    final taskMap = <String, TaskModel>{};
    final dayMap  = <int, RoadmapDayModel>{};

    for (final item in seed) {
      final day   = item['day']   as RoadmapDayModel;
      final tasks = item['tasks'] as List<TaskModel>;
      dayMap[day.dayNumber] = day;
      for (final t in tasks) taskMap[t.id] = t;
    }
    
    await _tasks.clear(); // Effacer les anciennes tâches pour éviter un empilement de UUID
    await _days.clear();  // S'assurer que les anciens jours sont bien vidés avant réécriture
    await _days.putAll(dayMap); // Écraser les anciens jours
    await _tasks.putAll(taskMap); // Insérer les nouvelles tâches à zéro
    
    // NB: On ne vide plus _settings pour conserver le paramétrage (AgentID, notifs)
  }
}
