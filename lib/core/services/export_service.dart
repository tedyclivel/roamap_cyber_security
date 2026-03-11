// lib/core/services/export_service.dart

import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';

class ExportService {
  static String generateMissionLog(UserProgressEntity progress, List<RoadmapDayEntity> history) {
    final buffer = StringBuffer();
    buffer.writeln('======== IRON MIND MISSION LOG ========');
    buffer.writeln('AGENT_ID: ${progress.currentDay > 0 ? "AGENT_001" : "NEW_RECRUIT"}');
    buffer.writeln('VERSION: 1.0.4-STABLE');
    buffer.writeln('PROGRESSION: ${progress.globalProgression * 100}%');
    buffer.writeln('STREAK: ${progress.currentStreak} DAYS');
    buffer.writeln('TOTAL_XP: ${progress.totalPoints}');
    buffer.writeln('=======================================');
    buffer.writeln('');
    
    buffer.writeln('--- ARCHIVE ENTRIES ---');
    for (var day in history) {
      if (day.journalNote != null && day.journalNote!.isNotEmpty) {
        buffer.writeln('[DAY ${day.dayNumber}] (${day.date.toString().substring(0, 10)})');
        buffer.writeln('MOOD: ${day.moodScore}/5');
        buffer.writeln('NOTE: ${day.journalNote}');
        buffer.writeln('-----------------------');
      }
    }
    
    return buffer.toString();
  }
}
