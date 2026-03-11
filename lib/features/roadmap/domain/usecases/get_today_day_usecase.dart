// lib/features/roadmap/domain/usecases/get_today_day_usecase.dart

import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';

class GetTodayDayUseCase {
  final RoadmapRepository _repository;
  const GetTodayDayUseCase(this._repository);

  Future<RoadmapDayEntity> call() async {
    return await _repository.getTodayDay();
  }
}
