// lib/features/roadmap/data/repositories_impl/roadmap_repository_impl.dart
import 'package:iron_mind/features/roadmap/data/datasources/roadmap_local_datasource.dart';
import 'package:iron_mind/features/roadmap/data/models/task_model.dart';
import 'package:iron_mind/features/roadmap/data/models/user_progress_model.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';
import 'package:iron_mind/features/roadmap/data/models/app_settings_model.dart';
import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:iron_mind/core/constants/app_constants.dart';
import 'package:iron_mind/core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class RoadmapRepositoryImpl implements RoadmapRepository {
  final RoadmapLocalDataSource _ds;
  RoadmapRepositoryImpl(this._ds);

  @override
  Future<RoadmapDayEntity?> getDay(int dayNumber) async {
    final model = _ds.getDay(dayNumber);
    if (model == null) return null;
    final tasks = _ds.getTasksForDay(dayNumber);
    return model.toEntity(tasks);
  }

  @override
  Future<List<RoadmapDayEntity>> getAllDays() async {
    return _ds.getAllDays().map((d) => d.toEntity(_ds.getTasksForDay(d.dayNumber))).toList();
  }

  @override
  Future<RoadmapDayEntity> getTodayDay() async {
    final progress = _ds.getUserProgress();
    final dayNumber = progress?.currentDay ?? 1;
    final model = _ds.getDay(dayNumber);
    if (model == null) {
      // Pour éviter un crash fatal lors d'un "Wipe data", on renvoie un jour fictif en file d'attente
      return RoadmapDayEntity(
        dayNumber: dayNumber, 
        date: DateTime.now(), 
        totalPointsEarned: 0, 
        tasks: [],
      );
    }
    return model.toEntity(_ds.getTasksForDay(dayNumber));
  }

  @override
  Future<void> saveDay(RoadmapDayEntity day) async {
    final model = _ds.getDay(day.dayNumber);
    if (model != null) {
      model
        ..isCheckedIn       = day.isCheckedIn
        ..journalNote       = day.journalNote
        ..moodScore         = day.moodScore
        ..totalPointsEarned = day.totalPointsEarned;
      await model.save();
    }
  }

  @override
  Future<void> toggleTask(String taskId, int dayNumber, bool isCompleted) async {
    final progressModel = _ds.getUserProgress();
    if (progressModel == null) return;

    await _ds.toggleTask(taskId, isCompleted);
    
    // Recherche globale de la tâche par ID pour garantir la lecture des métadonnées (titre, points)
    final allTasks = HiveService.tasks.values;
    final matching = allTasks.where((t) => t.id == taskId);
    if (matching.isEmpty) return;
    
    final task = matching.first;
    final multiplier = isCompleted ? 1 : -1;
    final pts = task.points * multiplier;

    // 1. Mise à jour des points et niveau
    progressModel.totalPoints = (progressModel.totalPoints + pts).clamp(0, 999999).toInt();
    progressModel.level       = UserProgressEntity.calculateLevel(progressModel.totalPoints);

    // 2. Smart KPI Sync : Analyse intelligente du titre
    final title = task.title.toUpperCase();
    
    // Algorithmes (ex: [ALG] Codeforces : 2 problèmes)
    if (title.contains('ALG') || title.contains('CODEFORCES')) {
      final match = RegExp(r'(\d+)').firstMatch(title);
      if (match != null) {
        progressModel.completedCodeforcesProblems = (progressModel.completedCodeforcesProblems + (int.parse(match.group(1)!) * multiplier)).clamp(0, 999999).toInt();
      }
    } 
    // Compétitions (ex: [CMP] Contest)
    else if (title.contains('CMP') || title.contains('CONTEST')) {
      progressModel.completedContests = (progressModel.completedContests + multiplier).clamp(0, 999999).toInt();
    }
    // Cyber & CTF (ex: [CYB] HackTheBox, Machine HTB)
    else if (title.contains('CYB') || title.contains('CTF') || title.contains('HACKTHEBOX') || title.contains('HTB')) {
      if (title.contains('MACHINE') || title.contains('HACKTHEBOX') || title.contains('HTB')) {
        progressModel.completedCtfMachines = (progressModel.completedCtfMachines + multiplier).clamp(0, 999999).toInt();
      } else {
        progressModel.completedCyberLabs = (progressModel.completedCyberLabs + multiplier).clamp(0, 999999).toInt();
      }
    }

    // 3. Sauvegarde via DataSource (force le put dans Hive)
    await _ds.saveUserProgress(progressModel);
  }

  @override
  Future<List<TaskEntity>> getTasksForDay(int dayNumber) async {
    return _ds.getTasksForDay(dayNumber).map((t) => t.toEntity()).toList();
  }

  @override
  Future<void> checkInDay(int dayNumber, {String? journalNote, int? moodScore}) async {
    final model = _ds.getDay(dayNumber);
    if (model == null) return;

    // 1. Validation de la journée
    model.isCheckedIn = true;
    if (journalNote != null) model.journalNote = journalNote;
    if (moodScore   != null) model.moodScore   = moodScore;
    await model.save();
    
    await _updateStreak();
    await _updatePoints(AppConstants.pointsPerDayComplete);
  }

  @override
  Future<UserProgressEntity> getUserProgress() async {
    final model = _ds.getUserProgress();
    return model?.toEntity() ?? _defaultProgress();
  }

  @override
  Future<void> saveUserProgress(UserProgressEntity progress) async {
    await _ds.saveUserProgress(UserProgressModel.fromEntity(progress));
  }

  @override
  Future<void> updateKpi({int? codeforcesProblems, int? ctfMachines, int? cyberLabs, int? contests, int? pompesPR, int? gainagePR}) async {
    final model = _ds.getUserProgress();
    if (model == null) return;
    if (codeforcesProblems != null) model.completedCodeforcesProblems = codeforcesProblems;
    if (ctfMachines        != null) model.completedCtfMachines        = ctfMachines;
    if (cyberLabs          != null) model.completedCyberLabs          = cyberLabs;
    if (contests           != null) model.completedContests           = contests;
    if (pompesPR           != null) model.pompesPR                    = pompesPR;
    if (gainagePR          != null) model.gainagePR                   = gainagePR;
    await model.save();
  }

  @override
  Future<void> saveJournalNote(int dayNumber, String note) async =>
      _ds.saveJournalNote(dayNumber, note);

  @override
  Future<String?> getJournalNote(int dayNumber) async =>
      _ds.getDay(dayNumber)?.journalNote;

  @override
  Future<void> initializeRoadmap(DateTime startDate) async =>
      _ds.initializeRoadmap(startDate);

  @override
  Future<bool> isRoadmapInitialized() async => _ds.isInitialized();

  @override
  Future<AppSettingsEntity> getAppSettings() async {
    return _ds.getAppSettings().toEntity();
  }

  @override
  Future<void> saveAppSettings(AppSettingsEntity settings) async {
    await _ds.saveAppSettings(AppSettingsModel.fromEntity(settings));
  }

  // ── Helpers privés ────────────────────────────────────────────────
  Future<void> _updatePoints(int delta) async {
    final model = _ds.getUserProgress();
    if (model == null) return;
    model.totalPoints = (model.totalPoints + delta).clamp(0, 999999);
    model.level       = UserProgressEntity.calculateLevel(model.totalPoints);
    await model.save();
  }

  Future<void> _updateStreak() async {
    final model = _ds.getUserProgress();
    if (model == null) return;
    model.currentStreak++;
    if (model.currentStreak > model.maxStreak) model.maxStreak = model.currentStreak;
    if (model.currentStreak % 7 == 0) model.totalPoints += AppConstants.pointsPerStreak7Days;
    model.currentDay = (model.currentDay + 1).clamp(1, AppConstants.totalDays);
    await model.save();
  }

  @override
  Future<void> wipeData() async {
    await _ds.clearAllData();
  }

  UserProgressEntity _defaultProgress() => UserProgressEntity(
    currentDay: 1, totalPoints: 0, currentStreak: 0, maxStreak: 0, level: 1,
    completedCodeforcesProblems: 0, completedCtfMachines: 0, completedCyberLabs: 0,
    completedContests: 0, pompesPR: 0, gainagePR: 0, totalDeepWorkMinutes: 0,
    startDate: DateTime.now(), unlockedBadgeIds: [],
  );
}
