// lib/features/roadmap/domain/entities/task_entity.dart

import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';

class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final DomainType domain;
  final bool isCompleted;
  final bool isOptional;   // tâches avancées au-delà de l'objectif
  final bool isBonus;      // défis supplémentaires (gamification)
  final int points;
  final DateTime date;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.domain,
    this.isCompleted = false,
    this.isOptional = false,
    this.isBonus = false,
    required this.points,
    required this.date,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DomainType? domain,
    bool? isCompleted,
    bool? isOptional,
    bool? isBonus,
    int? points,
    DateTime? date,
  }) {
    return TaskEntity(
      id:          id          ?? this.id,
      title:       title       ?? this.title,
      description: description ?? this.description,
      domain:      domain      ?? this.domain,
      isCompleted: isCompleted ?? this.isCompleted,
      isOptional:  isOptional  ?? this.isOptional,
      isBonus:     isBonus     ?? this.isBonus,
      points:      points      ?? this.points,
      date:        date        ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TaskEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
