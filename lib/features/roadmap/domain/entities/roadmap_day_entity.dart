// lib/features/roadmap/domain/entities/roadmap_day_entity.dart

import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/core/constants/app_constants.dart';

class RoadmapDayEntity {
  final int dayNumber;           // 1..120
  final DateTime date;
  final List<TaskEntity> tasks;
  final bool isCheckedIn;        // check-in quotidien validé
  final String? journalNote;
  final int moodScore;           // 1..5
  final int totalPointsEarned;

  const RoadmapDayEntity({
    required this.dayNumber,
    required this.date,
    required this.tasks,
    this.isCheckedIn = false,
    this.journalNote,
    this.moodScore = 3,
    this.totalPointsEarned = 0,
  });

  int get phase {
    if (dayNumber <= 30) return 1;
    if (dayNumber <= 60) return 2;
    if (dayNumber <= 90) return 3;
    return 4;
  }

  String get phaseLabel {
    switch (phase) {
      case 1: return 'Phase 1 — Fondations';
      case 2: return 'Phase 2 — Montée en puissance';
      case 3: return 'Phase 3 — Niveau avancé';
      case 4: return 'Phase 4 — Red Team Junior';
      default: return 'Phase ?';
    }
  }

  bool get isEndOfMonth => dayNumber > 0 && dayNumber % 30 == 0;

  double get completionRate {
    if (tasks.isEmpty) return 0;
    final required = tasks.where((t) => !t.isOptional && !t.isBonus).toList();
    if (required.isEmpty) return 0;
    final done = required.where((t) => t.isCompleted).length;
    return done / required.length;
  }

  bool get isDayComplete => completionRate >= 1.0;

  List<TaskEntity> get requiredTasks => tasks.where((t) => !t.isOptional && !t.isBonus).toList();
  List<TaskEntity> get optionalTasks => tasks.where((t) => t.isOptional).toList();
  List<TaskEntity> get bonusTasks    => tasks.where((t) => t.isBonus).toList();

  RoadmapDayEntity copyWith({
    int? dayNumber,
    DateTime? date,
    List<TaskEntity>? tasks,
    bool? isCheckedIn,
    String? journalNote,
    int? moodScore,
    int? totalPointsEarned,
  }) {
    return RoadmapDayEntity(
      dayNumber:          dayNumber          ?? this.dayNumber,
      date:               date               ?? this.date,
      tasks:              tasks              ?? this.tasks,
      isCheckedIn:        isCheckedIn        ?? this.isCheckedIn,
      journalNote:        journalNote        ?? this.journalNote,
      moodScore:          moodScore          ?? this.moodScore,
      totalPointsEarned:  totalPointsEarned  ?? this.totalPointsEarned,
    );
  }
}
