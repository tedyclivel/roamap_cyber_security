// lib/features/roadmap/domain/usecases/get_user_progress_usecase.dart

import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';

class GetUserProgressUseCase {
  final RoadmapRepository _repository;
  const GetUserProgressUseCase(this._repository);

  Future<UserProgressEntity> call() async {
    return await _repository.getUserProgress();
  }
}
