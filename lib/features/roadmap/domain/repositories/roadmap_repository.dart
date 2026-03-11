// lib/features/roadmap/domain/repositories/roadmap_repository.dart

import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';

abstract class RoadmapRepository {
  // ── Jours ─────────────────────────────────────────────────────────
  Future<RoadmapDayEntity?> getDay(int dayNumber);
  Future<List<RoadmapDayEntity>> getAllDays();
  Future<RoadmapDayEntity> getTodayDay();
  Future<void> saveDay(RoadmapDayEntity day);

  // ── Tâches ────────────────────────────────────────────────────────
  Future<void> toggleTask(String taskId, int dayNumber, bool isCompleted);
  Future<List<TaskEntity>> getTasksForDay(int dayNumber);

  // ── Check-in quotidien ────────────────────────────────────────────
  Future<void> checkInDay(int dayNumber, {String? journalNote, int? moodScore});

  // ── Progression utilisateur ───────────────────────────────────────
  Future<UserProgressEntity> getUserProgress();
  Future<void> saveUserProgress(UserProgressEntity progress);
  Future<void> updateKpi({
    int? codeforcesProblems,
    int? ctfMachines,
    int? cyberLabs,
    int? contests,
    int? pompesPR,
    int? gainagePR,
  });

  // ── Journal ───────────────────────────────────────────────────────
  Future<void> saveJournalNote(int dayNumber, String note);
  Future<String?> getJournalNote(int dayNumber);

  // ── Initialisation ────────────────────────────────────────────────
  Future<void> initializeRoadmap(DateTime startDate);
  Future<bool> isRoadmapInitialized();

  // ── Paramètres ───────────────────────────────────────────────────
  Future<AppSettingsEntity> getAppSettings();
  Future<void> saveAppSettings(AppSettingsEntity settings);
  Future<void> wipeData();
}
