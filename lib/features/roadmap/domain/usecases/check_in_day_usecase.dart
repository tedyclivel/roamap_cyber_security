// lib/features/roadmap/domain/usecases/check_in_day_usecase.dart

import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';

class CheckInDayUseCase {
  final RoadmapRepository _repository;
  const CheckInDayUseCase(this._repository);

  Future<void> call({
    required int dayNumber,
    String? journalNote,
    int? moodScore,
  }) async {
    await _repository.checkInDay(
      dayNumber,
      journalNote: journalNote,
      moodScore: moodScore,
    );
  }
}
