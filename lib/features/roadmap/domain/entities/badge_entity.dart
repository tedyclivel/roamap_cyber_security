import 'package:flutter/material.dart';

enum BadgeType {
  streak7,   streak30,  streak60,  streak120,
  level3,    level5,    level7,
  pompes60,  codeforces50, ctf10, fullDay, perfectWeek,
}

class BadgeEntity {
  final BadgeType type;
  final String    id;
  final IconData  icon;
  final String    label;
  final String    description;
  final bool      isUnlocked;

  const BadgeEntity({
    required this.type,
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    this.isUnlocked = false,
  });

  BadgeEntity copyWith({bool? isUnlocked}) => BadgeEntity(
    type:        type,
    id:          id,
    icon:        icon,
    label:       label,
    description: description,
    isUnlocked:  isUnlocked ?? this.isUnlocked,
  );

  // ── Catalogue complet des badges ─────────────────────────────────
  static List<BadgeEntity> catalog() => const [
    BadgeEntity(type: BadgeType.streak7,       id: 'streak_7',       icon: Icons.local_fire_department_rounded, label: 'Week Warrior',      description: '7 jours de suite sans interruption'),
    BadgeEntity(type: BadgeType.streak30,      id: 'streak_30',      icon: Icons.bolt_rounded,                  label: 'Iron Discipline',   description: '30 jours de suite'),
    BadgeEntity(type: BadgeType.streak60,      id: 'streak_60',      icon: Icons.timer_off_rounded,             label: 'No Days Off',       description: '60 jours de suite'),
    BadgeEntity(type: BadgeType.streak120,     id: 'streak_120',     icon: Icons.workspace_premium_rounded,     label: 'IRON MIND',         description: '120 jours complets'),
    BadgeEntity(type: BadgeType.level3,        id: 'level_3',        icon: Icons.shield_rounded,                label: 'Hacker Confirmé',  description: 'Atteindre le niveau 3'),
    BadgeEntity(type: BadgeType.level5,        id: 'level_5',        icon: Icons.military_tech_rounded,          label: 'Elite Performer', description: 'Atteindre le niveau 5'),
    BadgeEntity(type: BadgeType.level7,        id: 'level_7',        icon: Icons.psychology_rounded,            label: 'Iron Mind',         description: 'Niveau maximum atteint !'),
    BadgeEntity(type: BadgeType.pompes60,      id: 'pompes_60',      icon: Icons.fitness_center_rounded,        label: 'Beast Mode',        description: '60 pompes en une série'),
    BadgeEntity(type: BadgeType.codeforces50,  id: 'cf_50',          icon: Icons.code_rounded,                  label: 'Code Warrior',      description: '50 problèmes Codeforces résolus'),
    BadgeEntity(type: BadgeType.ctf10,         id: 'ctf_10',         icon: Icons.gps_fixed_rounded,             label: 'Flag Hunter',       description: '10 machines CTF résolues'),
    BadgeEntity(type: BadgeType.fullDay,       id: 'full_day',       icon: Icons.star_rounded,                  label: '100% Day',          description: 'Toutes les tâches du jour complétées'),
    BadgeEntity(type: BadgeType.perfectWeek,   id: 'perfect_week',   icon: Icons.emoji_events_rounded,          label: 'Perfect Week',      description: '7 jours à 100% de complétion'),
  ];
}
