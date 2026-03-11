// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // ── Application ─────────────────────────────────────────────────────
  static const String appName       = 'IRON MIND';
  static const String appVersion    = '1.0.0';
  static const String appTagline    = '>_ ELITE PERFORMANCE TRACKER';

  // ── Roadmap ──────────────────────────────────────────────────────────
  static const int totalDays        = 120;
  static const int daysPerPhase     = 30;
  static const int totalPhases      = 4;

  // ── Domaines ─────────────────────────────────────────────────────────
  static const String domainPhysique = 'Physique';
  static const String domainAlgo     = 'Algorithmique';
  static const String domainCyber    = 'Cybersécurité';
  static const String domainMental   = 'Mental';
  static const String domainLinux    = 'Linux / Dev';

  // ── Objectifs finaux ─────────────────────────────────────────────────
  static const int targetPompes          = 60;
  static const int targetGainage         = 180; // en secondes (3 min)
  static const int targetCodeforces      = 150;
  static const int targetContests        = 8;
  static const int targetCtfMachines     = 40;
  static const int targetDeepWorkMinutes = 18000; // 300 heures sur 4 mois
  static const double targetMuscleKg     = 4.5; // cible moyenne +3 à +6 kg

  // ── Gamification ─────────────────────────────────────────────────────
  static const int pointsPerTask         = 10;
  static const int pointsPerDayComplete  = 50;
  static const int pointsPerStreak7Days  = 100;
  static const int pointsPerPhaseComplete = 500;

  // ── Hive / Isar Storage ──────────────────────────────────────────────
  static const String progressBoxName    = 'iron_progress';
  static const String settingsBoxName    = 'iron_settings';
  static const String journalBoxName     = 'iron_journal';

  // ── Notifications ─────────────────────────────────────────────────────
  static const String notifChannelId    = 'iron_mind_channel';
  static const String notifChannelName  = 'IRON MIND Alerts';
  static const int morningNotifHour     = 6;
  static const int morningNotifMinute   = 30;
  static const int eveningNotifHour     = 16;
  static const int eveningNotifMinute   = 30;
}
