// test/unit/usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';
import 'package:iron_mind/features/roadmap/domain/entities/badge_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';

void main() {
  group('UserProgressEntity — Niveaux', () {
    test('Niveau 1 avec 0 points', () {
      expect(UserProgressEntity.calculateLevel(0), equals(1));
    });
    test('Niveau 1 avec 200 points', () {
      expect(UserProgressEntity.calculateLevel(200), equals(1));
    });
    test('Niveau 2 avec 600 points', () {
      expect(UserProgressEntity.calculateLevel(600), equals(2));
    });
    test('Niveau 4 avec 5000 points', () {
      expect(UserProgressEntity.calculateLevel(5000), equals(4));
    });
    test('Niveau 7 avec 25000 points', () {
      expect(UserProgressEntity.calculateLevel(25000), equals(7));
    });
    test('Titre niveau 1 = Script Kiddie', () {
      expect(UserProgressEntity.levelTitle(1), equals('Script Kiddie'));
    });
    test('Titre niveau 7 = Iron Mind', () {
      expect(UserProgressEntity.levelTitle(7), equals('Iron Mind'));
    });
    test('LevelProgress entre 0 et 1', () {
      final progress = UserProgressEntity(
        currentDay: 1, totalPoints: 150, currentStreak: 0, maxStreak: 0,
        level: 1, completedCodeforcesProblems: 0, completedCtfMachines: 0,
        completedCyberLabs: 0, completedContests: 0, pompesPR: 0, gainagePR: 0,
        startDate: DateTime(2025), unlockedBadgeIds: [],
      );
      expect(progress.levelProgress, greaterThanOrEqualTo(0.0));
      expect(progress.levelProgress, lessThanOrEqualTo(1.0));
    });
  });

  group('UserProgressEntity — Progression globale', () {
    test('Progression globale = currentDay / 120', () {
      final p = UserProgressEntity(
        currentDay: 60, totalPoints: 0, currentStreak: 0, maxStreak: 0,
        level: 1, completedCodeforcesProblems: 0, completedCtfMachines: 0,
        completedCyberLabs: 0, completedContests: 0, pompesPR: 0, gainagePR: 0,
        startDate: DateTime(2025), unlockedBadgeIds: [],
      );
      expect(p.globalProgression, closeTo(0.5, 0.01));
    });
  });

  group('DomainType', () {
    test('Physique a le bon index', () {
      expect(DomainType.physique.index, equals(0));
    });
    test('Couleurs définies pour tous les domaines', () {
      for (final d in DomainType.values) {
        expect(d.color, isNotNull);
        expect(d.label, isNotEmpty);
        expect(d.emoji, isNotEmpty);
      }
    });
  });

  group('BadgeEntity — Catalogue', () {
    test('Catalogue contient 12 badges', () {
      final catalog = BadgeEntity.catalog();
      expect(catalog.length, equals(12));
    });
    test('Tous les badges ont un id unique', () {
      final catalog = BadgeEntity.catalog();
      final ids = catalog.map((b) => b.id).toSet();
      expect(ids.length, equals(catalog.length));
    });
    test('Badges verrouillés par défaut', () {
      final catalog = BadgeEntity.catalog();
      expect(catalog.every((b) => !b.isUnlocked), isTrue);
    });
  });

  group('TaskEntity', () {
    test('Une tâche bonus a isBonus = true', () {
      final task = TaskEntity(
        id: '1', title: 'Test', domain: DomainType.cyber,
        isCompleted: false, isOptional: false, isBonus: true,
        points: 25, date: DateTime(2025),
      );
      expect(task.isBonus, isTrue);
    });
  });

  group('RoadmapDayEntity — Phase', () {
    test('Jour 1 = Phase 1', () {
      final day = RoadmapDayEntity(
        dayNumber: 1, date: DateTime(2025), tasks: [],
        isCheckedIn: false, moodScore: 3, totalPointsEarned: 0,
      );
      expect(day.phase, equals(1));
    });
    test('Jour 60 = Phase 2', () {
      final day = RoadmapDayEntity(
        dayNumber: 60, date: DateTime(2025), tasks: [],
        isCheckedIn: false, moodScore: 3, totalPointsEarned: 0,
      );
      expect(day.phase, equals(2));
    });
    test('Jour 120 = Phase 4', () {
      final day = RoadmapDayEntity(
        dayNumber: 120, date: DateTime(2025), tasks: [],
        isCheckedIn: false, moodScore: 3, totalPointsEarned: 0,
      );
      expect(day.phase, equals(4));
    });
    test('Completion rate = 0 si aucune tâche requise', () {
      final day = RoadmapDayEntity(
        dayNumber: 1, date: DateTime(2025), tasks: [],
        isCheckedIn: false, moodScore: 3, totalPointsEarned: 0,
      );
      expect(day.completionRate, equals(0.0));
    });
  });
}
