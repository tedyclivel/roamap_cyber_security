// lib/features/roadmap/presentation/providers/roadmap_providers.dart

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/roadmap/data/datasources/roadmap_local_datasource.dart';
import 'package:iron_mind/features/roadmap/data/repositories_impl/roadmap_repository_impl.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:iron_mind/features/roadmap/domain/usecases/check_in_day_usecase.dart';
import 'package:iron_mind/features/roadmap/domain/usecases/get_today_day_usecase.dart';
import 'package:iron_mind/features/roadmap/domain/usecases/get_user_progress_usecase.dart';
import 'package:iron_mind/features/roadmap/domain/usecases/toggle_task_usecase.dart';
import 'package:iron_mind/features/roadmap/domain/usecases/update_kpi_usecase.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';

// ── Infrastructure ────────────────────────────────────────────────────
final dataSourceProvider = Provider<RoadmapLocalDataSource>((ref) {
  return RoadmapLocalDataSource();
});

final repositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepositoryImpl(ref.watch(dataSourceProvider));
});

// ── Usecases ──────────────────────────────────────────────────────────
final getTodayUseCaseProvider    = Provider((ref) => GetTodayDayUseCase(ref.watch(repositoryProvider)));
final toggleTaskUseCaseProvider  = Provider((ref) => ToggleTaskUseCase(ref.watch(repositoryProvider)));
final checkInUseCaseProvider     = Provider((ref) => CheckInDayUseCase(ref.watch(repositoryProvider)));
final getProgressUseCaseProvider = Provider((ref) => GetUserProgressUseCase(ref.watch(repositoryProvider)));
final updateKpiUseCaseProvider   = Provider((ref) => UpdateKpiUseCase(ref.watch(repositoryProvider)));

// ── Provider : Journée courante ───────────────────────────────────────
final todayDayProvider = AsyncNotifierProvider<TodayDayNotifier, RoadmapDayEntity>(
  TodayDayNotifier.new,
);

class TodayDayNotifier extends AsyncNotifier<RoadmapDayEntity> {
  @override
  Future<RoadmapDayEntity> build() async {
    return await ref.watch(getTodayUseCaseProvider).call();
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    final day = state.valueOrNull;
    if (day == null) return;
    
    state = AsyncData(day.copyWith(
      tasks: day.tasks.map((t) => t.id == taskId ? t.copyWith(isCompleted: isCompleted) : t).toList(),
    ));

    await ref.read(toggleTaskUseCaseProvider).call(taskId: taskId, dayNumber: day.dayNumber, isCompleted: isCompleted);
    ref.invalidate(userProgressProvider);
    ref.invalidate(allDaysProvider);
  }

  Future<void> checkIn({String? journalNote, int? moodScore}) async {
    final day = state.valueOrNull;
    if (day == null) return;
    await ref.read(checkInUseCaseProvider).call(dayNumber: day.dayNumber, journalNote: journalNote, moodScore: moodScore);
    state = AsyncData(day.copyWith(isCheckedIn: true, journalNote: journalNote, moodScore: moodScore));
    ref.invalidate(userProgressProvider);
    ref.invalidate(allDaysProvider);
  }

  Future<void> saveJournalNote(String note) async {
    final day = state.valueOrNull;
    if (day == null) return;
    await ref.read(repositoryProvider).saveJournalNote(day.dayNumber, note);
    state = AsyncData(day.copyWith(journalNote: note));
    ref.invalidate(allDaysProvider);
  }
}

// ── Provider : Progression utilisateur ───────────────────────────────
final userProgressProvider = AsyncNotifierProvider<UserProgressNotifier, UserProgressEntity>(
  UserProgressNotifier.new,
);

class UserProgressNotifier extends AsyncNotifier<UserProgressEntity> {
  @override
  Future<UserProgressEntity> build() async {
    final progress = await ref.watch(getProgressUseCaseProvider).call();
    return await _checkAndUnlockBadges(progress);
  }

  Future<void> updateKpi({int? codeforcesProblems, int? ctfMachines, int? cyberLabs, int? contests, int? pompesPR, int? gainagePR}) async {
    await ref.read(updateKpiUseCaseProvider).call(
      codeforcesProblems: codeforcesProblems,
      ctfMachines: ctfMachines,
      cyberLabs: cyberLabs,
      contests: contests,
      pompesPR: pompesPR,
      gainagePR: gainagePR,
    );
    ref.invalidateSelf();
  }

  Future<void> addDeepWorkMinutes(int minutes) async {
    final p = state.valueOrNull;
    if (p == null) return;
    final updated = p.copyWith(totalDeepWorkMinutes: p.totalDeepWorkMinutes + minutes);
    await ref.read(repositoryProvider).saveUserProgress(updated);
    state = AsyncData(updated);
    ref.invalidate(allDaysProvider); // Pour mettre à jour les graphiques si besoin
  }

  Future<UserProgressEntity> _checkAndUnlockBadges(UserProgressEntity p) async {
    final unlocked = Set<String>.from(p.unlockedBadgeIds);
    final initialCount = unlocked.length;

    // Conditions de déblocage
    if (p.maxStreak >= 7)   unlocked.add('streak_7');
    if (p.maxStreak >= 30)  unlocked.add('streak_30');
    if (p.maxStreak >= 60)  unlocked.add('streak_60');
    if (p.maxStreak >= 120) unlocked.add('streak_120');

    if (p.level >= 3) unlocked.add('level_3');
    if (p.level >= 5) unlocked.add('level_5');
    if (p.level >= 7) unlocked.add('level_7');

    if (p.pompesPR >= 60)               unlocked.add('pompes_60');
    if (p.completedCodeforcesProblems >= 50) unlocked.add('cf_50');
    if (p.completedCtfMachines >= 10)        unlocked.add('ctf_10');

    // Si de nouveaux badges sont débloqués, on sauvegarde
    if (unlocked.length > initialCount) {
      final updated = p.copyWith(unlockedBadgeIds: unlocked.toList());
      await ref.read(repositoryProvider).saveUserProgress(updated);
      return updated;
    }

    return p;
  }
}

// ── Provider : Tous les jours ─────────────────────────────────────────
final allDaysProvider = FutureProvider<List<RoadmapDayEntity>>((ref) async {
  return await ref.watch(repositoryProvider).getAllDays();
});

// ── Provider : Deep Work Chronomètre ─────────────────────────────────
class DeepWorkState {
  final int seconds;
  final bool isActive;
  final bool isBackgrounded;

  DeepWorkState({this.seconds = 0, this.isActive = false, this.isBackgrounded = false});

  DeepWorkState copyWith({int? seconds, bool? isActive, bool? isBackgrounded}) {
    return DeepWorkState(
      seconds: seconds ?? this.seconds,
      isActive: isActive ?? this.isActive,
      isBackgrounded: isBackgrounded ?? this.isBackgrounded,
    );
  }
}

final deepWorkProvider = StateNotifierProvider<DeepWorkNotifier, DeepWorkState>((ref) {
  return DeepWorkNotifier(ref);
});

class DeepWorkNotifier extends StateNotifier<DeepWorkState> with WidgetsBindingObserver {
  final Ref ref;
  Timer? _timer;

  DeepWorkNotifier(this.ref) : super(DeepWorkState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (this.state.isActive) {
        pause(backgrounded: true);
      }
    }
  }

  void toggle() {
    if (state.isActive) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    state = state.copyWith(isActive: true, isBackgrounded: false);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(seconds: state.seconds + 1);
    });
  }

  void pause({bool backgrounded = false}) {
    _timer?.cancel();
    state = state.copyWith(isActive: false, isBackgrounded: backgrounded);
  }

  void reset(int newSeconds) {
    pause();
    state = state.copyWith(seconds: newSeconds, isActive: false, isBackgrounded: false);
  }

  void consumeSeconds(int consumed) {
     state = state.copyWith(seconds: state.seconds - consumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}

// ── Provider : Paramètres ─────────────────────────────────────────────
final appSettingsProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettingsEntity>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends AsyncNotifier<AppSettingsEntity> {
  @override
  Future<AppSettingsEntity> build() async {
    return await ref.watch(repositoryProvider).getAppSettings();
  }

  Future<void> updateSettings(AppSettingsEntity newSettings) async {
    state = AsyncData(newSettings);
    await ref.read(repositoryProvider).saveAppSettings(newSettings);
  }
}
