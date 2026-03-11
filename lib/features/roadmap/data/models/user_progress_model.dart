// lib/features/roadmap/data/models/user_progress_model.dart
import 'package:hive/hive.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';

class UserProgressModel extends HiveObject {
  int           currentDay;
  int           totalPoints;
  int           currentStreak;
  int           maxStreak;
  int           level;
  int           completedCodeforcesProblems;
  int           completedCtfMachines;
  int           completedCyberLabs;
  int           completedContests;
  int           pompesPR;
  int           gainagePR;
  int           totalDeepWorkMinutes;
  DateTime      startDate;
  List<String>  unlockedBadgeIds;

  UserProgressModel({
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

  static UserProgressModel fromEntity(UserProgressEntity e) => UserProgressModel(
    currentDay:                  e.currentDay,
    totalPoints:                 e.totalPoints,
    currentStreak:               e.currentStreak,
    maxStreak:                   e.maxStreak,
    level:                       e.level,
    completedCodeforcesProblems: e.completedCodeforcesProblems,
    completedCtfMachines:        e.completedCtfMachines,
    completedCyberLabs:          e.completedCyberLabs,
    completedContests:           e.completedContests,
    pompesPR:                    e.pompesPR,
    gainagePR:                   e.gainagePR,
    totalDeepWorkMinutes:        e.totalDeepWorkMinutes,
    startDate:                   e.startDate,
    unlockedBadgeIds:            e.unlockedBadgeIds,
  );

  UserProgressEntity toEntity() => UserProgressEntity(
    currentDay:                  currentDay,
    totalPoints:                 totalPoints,
    currentStreak:               currentStreak,
    maxStreak:                   maxStreak,
    level:                       level,
    completedCodeforcesProblems: completedCodeforcesProblems,
    completedCtfMachines:        completedCtfMachines,
    completedCyberLabs:          completedCyberLabs,
    completedContests:           completedContests,
    pompesPR:                    pompesPR,
    gainagePR:                   gainagePR,
    totalDeepWorkMinutes:        totalDeepWorkMinutes,
    startDate:                   startDate,
    unlockedBadgeIds:            unlockedBadgeIds,
  );

  Map<String, dynamic> toMap() => {
    'currentDay':                  currentDay,
    'totalPoints':                 totalPoints,
    'currentStreak':               currentStreak,
    'maxStreak':                   maxStreak,
    'level':                       level,
    'completedCodeforcesProblems': completedCodeforcesProblems,
    'completedCtfMachines':        completedCtfMachines,
    'completedCyberLabs':          completedCyberLabs,
    'completedContests':           completedContests,
    'pompesPR':                    pompesPR,
    'gainagePR':                   gainagePR,
    'totalDeepWorkMinutes':        totalDeepWorkMinutes,
    'startDate':                   startDate.millisecondsSinceEpoch,
    'unlockedBadgeIds':            unlockedBadgeIds,
  };

  static UserProgressModel fromMap(Map<dynamic, dynamic> m) => UserProgressModel(
    currentDay:                  m['currentDay'] as int,
    totalPoints:                 m['totalPoints'] as int,
    currentStreak:               m['currentStreak'] as int,
    maxStreak:                   m['maxStreak'] as int,
    level:                       m['level'] as int,
    completedCodeforcesProblems: m['completedCodeforcesProblems'] as int,
    completedCtfMachines:        m['completedCtfMachines'] as int,
    completedCyberLabs:          m['completedCyberLabs'] as int,
    completedContests:           m['completedContests'] as int,
    pompesPR:                    m['pompesPR'] as int,
    gainagePR:                   m['gainagePR'] as int,
    totalDeepWorkMinutes:        (m['totalDeepWorkMinutes'] as int?) ?? 0,
    startDate:                   DateTime.fromMillisecondsSinceEpoch(m['startDate'] as int),
    unlockedBadgeIds:            List<String>.from(m['unlockedBadgeIds'] as List),
  );
}

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override final int typeId = 2;

  @override
  UserProgressModel read(BinaryReader reader) {
    return UserProgressModel.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer.writeMap(obj.toMap());
  }
}
