// lib/features/roadmap/data/models/roadmap_day_model.dart
import 'package:hive/hive.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/data/models/task_model.dart';

class RoadmapDayModel extends HiveObject {
  int      dayNumber;
  DateTime date;
  bool     isCheckedIn;
  String?  journalNote;
  int      moodScore;
  int      totalPointsEarned;

  RoadmapDayModel({
    required this.dayNumber,
    required this.date,
    this.isCheckedIn = false,
    this.journalNote,
    this.moodScore = 3,
    this.totalPointsEarned = 0,
  });

  RoadmapDayEntity toEntity(List<TaskModel> tasks) => RoadmapDayEntity(
    dayNumber:         dayNumber,
    date:              date,
    tasks:             tasks.map((t) => t.toEntity()).toList(),
    isCheckedIn:       isCheckedIn,
    journalNote:       journalNote,
    moodScore:         moodScore,
    totalPointsEarned: totalPointsEarned,
  );

  Map<String, dynamic> toMap() => {
    'dayNumber':         dayNumber,
    'date':              date.millisecondsSinceEpoch,
    'isCheckedIn':       isCheckedIn,
    'journalNote':       journalNote,
    'moodScore':         moodScore,
    'totalPointsEarned': totalPointsEarned,
  };

  static RoadmapDayModel fromMap(Map<dynamic, dynamic> m) => RoadmapDayModel(
    dayNumber:         m['dayNumber'] as int,
    date:              DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    isCheckedIn:       m['isCheckedIn'] as bool,
    journalNote:       m['journalNote'] as String?,
    moodScore:         m['moodScore'] as int,
    totalPointsEarned: m['totalPointsEarned'] as int,
  );
}

class RoadmapDayModelAdapter extends TypeAdapter<RoadmapDayModel> {
  @override final int typeId = 1;

  @override
  RoadmapDayModel read(BinaryReader reader) {
    return RoadmapDayModel.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, RoadmapDayModel obj) {
    writer.writeMap(obj.toMap());
  }
}
