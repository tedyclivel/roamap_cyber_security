// lib/features/roadmap/domain/entities/user_progress_entity.dart

class UserProgressEntity {
  final int currentDay;          // 1..120
  final int totalPoints;
  final int currentStreak;       // jours consécutifs
  final int maxStreak;
  final int level;               // calculé depuis totalPoints
  final int completedCodeforcesProblems;
  final int completedCtfMachines;
  final int completedCyberLabs;
  final int completedContests;
  final int pompesPR;            // record personnel
  final int gainagePR;           // en secondes
  final int totalDeepWorkMinutes;
  final DateTime startDate;
  final List<String> unlockedBadgeIds;

  const UserProgressEntity({
    required this.currentDay,
    required this.totalPoints,
    required this.currentStreak,
    required this.maxStreak,
    required this.level,
    required this.completedCodeforcesProblems,
    required this.completedCtfMachines,
    required this.completedCyberLabs,
    required this.completedContests,
    required this.pompesPR,
    required this.gainagePR,
    required this.totalDeepWorkMinutes,
    required this.startDate,
    required this.unlockedBadgeIds,
  });

  // ── Niveau calculé dynamiquement ──────────────────────────────────
  static int calculateLevel(int points) {
    if (points < 500)   return 1;
    if (points < 1500)  return 2;
    if (points < 3500)  return 3;
    if (points < 7000)  return 4;
    if (points < 12000) return 5;
    if (points < 20000) return 6;
    return 7;
  }

  static String levelTitle(int level) {
    switch (level) {
      case 1: return 'Script Kiddie';
      case 2: return 'Apprenti Hacker';
      case 3: return 'Analyst';
      case 4: return 'Pentester';
      case 5: return 'Red Teamer';
      case 6: return 'Elite Hacker';
      case 7: return 'Iron Mind';
      default: return 'Unknown';
    }
  }

  double get levelProgress {
    final thresholds = [0, 500, 1500, 3500, 7000, 12000, 20000, 30000];
    final currentLvl = calculateLevel(totalPoints);
    if (currentLvl >= 7) return 1.0;
    final low  = thresholds[currentLvl - 1];
    final high = thresholds[currentLvl];
    return (totalPoints - low) / (high - low);
  }

  double get globalProgression => currentDay / 120.0;

  UserProgressEntity copyWith({
    int? currentDay,
    int? totalPoints,
    int? currentStreak,
    int? maxStreak,
    int? level,
    int? completedCodeforcesProblems,
    int? completedCtfMachines,
    int? completedCyberLabs,
    int? completedContests,
    int? pompesPR,
    int? gainagePR,
    int? totalDeepWorkMinutes,
    DateTime? startDate,
    List<String>? unlockedBadgeIds,
  }) {
    return UserProgressEntity(
      currentDay:                   currentDay                   ?? this.currentDay,
      totalPoints:                  totalPoints                  ?? this.totalPoints,
      currentStreak:                currentStreak                ?? this.currentStreak,
      maxStreak:                    maxStreak                    ?? this.maxStreak,
      level:                        level                        ?? this.level,
      completedCodeforcesProblems:  completedCodeforcesProblems  ?? this.completedCodeforcesProblems,
      completedCtfMachines:         completedCtfMachines         ?? this.completedCtfMachines,
      completedCyberLabs:           completedCyberLabs           ?? this.completedCyberLabs,
      completedContests:            completedContests            ?? this.completedContests,
      pompesPR:                     pompesPR                     ?? this.pompesPR,
      gainagePR:                    gainagePR                    ?? this.gainagePR,
      totalDeepWorkMinutes:         totalDeepWorkMinutes          ?? this.totalDeepWorkMinutes,
      startDate:                    startDate                    ?? this.startDate,
      unlockedBadgeIds:             unlockedBadgeIds             ?? this.unlockedBadgeIds,
    );
  }
}
