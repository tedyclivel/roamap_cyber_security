// lib/features/roadmap/data/seeds/roadmap_seed.dart
import 'package:uuid/uuid.dart';
import 'package:iron_mind/features/roadmap/data/models/task_model.dart';
import 'package:iron_mind/features/roadmap/data/models/roadmap_day_model.dart';
import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';

const _uuid = Uuid();

class RoadmapSeed {
  static List<Map<String, dynamic>> generate(DateTime startDate) {
    final result = <Map<String, dynamic>>[];
    for (int day = 1; day <= 120; day++) {
      final date   = startDate.add(Duration(days: day - 1));
      final phase  = _getPhase(day);
      final tasks  = _generateTasksForDay(day, phase, date);
      final dayModel = RoadmapDayModel(
        dayNumber: day,
        date:      date,
      );
      result.add({'day': dayModel, 'tasks': tasks});
    }
    return result;
  }

  static int _getPhase(int day) {
    if (day <= 30)  return 1;
    if (day <= 60)  return 2;
    if (day <= 90)  return 3;
    return 4;
  }

  static List<TaskModel> _generateTasksForDay(int day, int phase, DateTime date) {
    final tasks    = <TaskModel>[];
    final sportDay = ((day - 1) % 7) + 1;
    final isRest   = sportDay == 3 || sportDay == 7;

    if (!isRest) {
      final isUpper = sportDay % 2 == 1;
      tasks.add(_task(
        day: day, date: date, domain: DomainType.physique, points: 10,
        title: isUpper ? '[PHY] Sport Haut du Corps' : '[PHY] Sport Bas du Corps',
        description: isUpper
          ? '4×max pompes • 4×10 dips • 3×45s gainage'
          : '4×20 squats • 3×12 fentes • 3×45s gainage',
      ));
    }
    tasks.add(_task(day: day, date: date, domain: DomainType.physique, points: 5,
      title: '[RCV] Étirements posture', description: '10 min. Dos, épaules, nuque.'));
    tasks.add(_task(day: day, date: date, domain: DomainType.algorithmique, points: 15,
      title: '[ALG] Codeforces : ${phase <= 2 ? 2 : 3} problème(s)', description: _algoTheme(phase)));
    if (phase >= 3 && day % 7 == 0) {
      tasks.add(_task(day: day, date: date, domain: DomainType.algorithmique, points: 30,
        title: '[CMP] Contest Codeforces', description: 'Objectif : résoudre ≥ 2 problèmes.', isOptional: true));
    }
    tasks.add(_task(day: day, date: date, domain: DomainType.cyber, points: 15,
      title: '[CYB] ${_cyberTitle(phase)}', description: _cyberDesc(phase)));
    tasks.add(_task(day: day, date: date, domain: DomainType.linux, points: 10,
      title: '[LNX] ${_linuxTitle(phase)}', description: _linuxDesc(phase)));
    tasks.add(_task(day: day, date: date, domain: DomainType.mental, points: 5,
      title: '[MNT] 10 min respiration', description: 'Respiration profonde ou méditation.'));
    tasks.add(_task(day: day, date: date, domain: DomainType.mental, points: 5,
      title: '[LOG] Journal du jour', description: 'Note tes accomplissements du jour.'));
    if (phase >= 2) {
      tasks.add(_task(day: day, date: date, domain: DomainType.cyber, points: 25,
        title: '[SYS] DÉFI AVANCÉ', description: _bonus(phase), isBonus: true));
    }
    return tasks;
  }

  static TaskModel _task({
    required int       day,
    required DateTime  date,
    required DomainType domain,
    required int       points,
    required String    title,
    String?            description,
    bool               isOptional = false,
    bool               isBonus    = false,
  }) =>
    TaskModel(
      id:          _uuid.v4(),
      title:       title,
      description: description,
      domainIndex: domain.index,
      isCompleted: false,
      isOptional:  isOptional,
      isBonus:     isBonus,
      points:      points,
      date:        date,
      dayNumber:   day,
    );

  static String _algoTheme(int p) {
    const m = ['Arrays, boucles, complexité. Niveau 800–1000.', 'Greedy, Two Pointers, Sorting.', 'Récursivité, BFS/DFS, DP simple.', 'Graphes, DP avancée. Rapidité.'];
    return m[p - 1];
  }
  static String _cyberTitle(int p) {
    const m = ['Lab TryHackMe Bases', 'Web Hacking', 'HackTheBox Machine', 'CTF Kill Chain'];
    return m[p - 1];
  }
  static String _cyberDesc(int p) {
    const m = ['NMap, Gobuster, Reconnaissance. TryHackMe Pre-Security.', 'XSS, SQLi, File Upload, Directory Traversal. PortSwigger.', 'Privilege Escalation, Reverse Shell. HTB Easy.', 'Exploitation complète. Metasploit, Burp Suite. HTB Medium.'];
    return m[p - 1];
  }
  static String _linuxTitle(int p) {
    const m = ['Linux Fondamentaux', 'Bash Scripting', 'Linux Avancé', 'Projets Dev'];
    return m[p - 1];
  }
  static String _linuxDesc(int p) {
    const m = ['ls, cd, grep, chmod, ps, kill, find.', 'Scripts bash d\'automatisation.', 'Processus, réseau, compilation.', '3 outils : scanner, brute-force, énumération.'];
    return m[p - 1];
  }
  static String _bonus(int p) {
    const m = ['', 'Script bash de scan réseau automatisé.', 'Root une machine HTB bonus.', 'Publier un Writeup HTB / blog.'];
    return m[p - 1];
  }
}
