// lib/features/roadmap/data/models/task_model.dart
import 'package:hive/hive.dart';
import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';

class TaskModel extends HiveObject {
  String   id;
  String   title;
  String?  description;
  int      domainIndex;
  bool     isCompleted;
  bool     isOptional;
  bool     isBonus;
  int      points;
  DateTime date;
  int      dayNumber;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.domainIndex,
    required this.isCompleted,
    required this.isOptional,
    required this.isBonus,
    required this.points,
    required this.date,
    required this.dayNumber,
  });

  DomainType get domain => DomainType.values[domainIndex];

  static TaskModel fromEntity(TaskEntity e, int day) => TaskModel(
    id:          e.id,
    title:       e.title,
    description: e.description,
    domainIndex: e.domain.index,
    isCompleted: e.isCompleted,
    isOptional:  e.isOptional,
    isBonus:     e.isBonus,
    points:      e.points,
    date:        e.date,
    dayNumber:   day,
  );

  TaskEntity toEntity() => TaskEntity(
    id:          id,
    title:       title,
    description: description,
    domain:      domain,
    isCompleted: isCompleted,
    isOptional:  isOptional,
    isBonus:     isBonus,
    points:      points,
    date:        date,
  );

  Map<String, dynamic> toMap() => {
    'id':          id,
    'title':       title,
    'description': description,
    'domainIndex': domainIndex,
    'isCompleted': isCompleted,
    'isOptional':  isOptional,
    'isBonus':     isBonus,
    'points':      points,
    'date':        date.millisecondsSinceEpoch,
    'dayNumber':   dayNumber,
  };

  static TaskModel fromMap(Map<dynamic, dynamic> m) => TaskModel(
    id:          m['id'] as String,
    title:       m['title'] as String,
    description: m['description'] as String?,
    domainIndex: m['domainIndex'] as int,
    isCompleted: m['isCompleted'] as bool,
    isOptional:  m['isOptional'] as bool,
    isBonus:     m['isBonus'] as bool,
    points:      m['points'] as int,
    date:        DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    dayNumber:   m['dayNumber'] as int,
  );
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    return TaskModel.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeMap(obj.toMap());
  }
}
