import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/services.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialise le service de notifications.
  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // Déterminer le fuseau horaire local de l'appareil (sans package externe pour éviter les erreurs de build)
    const platform = MethodChannel('com.ironmind.timezone');
    final String timeZoneName = await platform.invokeMethod('getLocalTimezone') ?? 'UTC';
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Planifie le rappel quotidien à l'heure souhaitée (ex: 8h00).
  static Future<void> scheduleDailyReminder({int hour = 8, int minute = 0}) async {
    await _plugin.cancelAll();

    final now     = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      '🛡️ IRON MIND — Mission du jour',
      'Tes tâches t\'attendent. Chaque jour compte. >_',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Rappels quotidiens',
          channelDescription: 'Rappel de la roadmap quotidienne IRON MIND',
          importance: Importance.max,
          priority:   Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode:     AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Planifie des rappels intelligents si les tâches ne sont pas terminées (Passive-Aggressive).
  static Future<void> scheduleSmartReminders() async {
    final nudges = [
      'L\'IA attend ton rapport de mission. Ne la fais pas attendre. >_',
      'Ta progression stagne. Veux-tu vraiment échouer ?',
      'Le Deep Work n\'est pas une option. Connecte-toi maintenant.',
      '60 pompes. 150 problèmes. Ton destin n\'attend pas.',
      'La discipline est la seule voie. Retourne au travail.',
      'Un hacker qui ne pratique pas est juste un touriste. Agis.',
    ];

    final now = tz.TZDateTime.now(tz.local);
    final times = [
      {'h': 14, 'm': 0},
      {'h': 18, 'm': 0},
      {'h': 21, 'm': 0},
    ];

    for (var i = 0; i < times.length; i++) {
      final t = times[i];
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, t['h']!, t['m']!);
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final message = nudges[scheduledDate.day % nudges.length];

      await _plugin.zonedSchedule(
        100 + i, // IDs uniques
        '🛡️ IRON MIND — RAPPEL_SYSTÈME',
        message,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nudge_reminders',
            'Rappels tactiques',
            channelDescription: 'Rappels pour maintenir la discipline',
            importance: Importance.max,
            priority:Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Notifie quand une tâche bonus est déverrouillée.
  static Future<void> showBonusUnlocked(String message) async {
    await _plugin.show(
      1,
      '⚡ DÉFI BONUS DÉVERROUILLÉ',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bonus_unlocked',
          'Bonus déverrouillés',
          importance: Importance.high,
          priority:   Priority.high,
        ),
      ),
    );
  }

  /// Notifie une montée de niveau.
  static Future<void> showLevelUp(int level, String title) async {
    await _plugin.show(
      2,
      '🏆 NIVEAU $level ATTEINT !',
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'level_up',
          'Montées de niveau',
          importance: Importance.high,
          priority:   Priority.high,
        ),
      ),
    );
  }
}
