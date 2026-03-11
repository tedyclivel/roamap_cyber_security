// lib/features/roadmap/domain/usecases/toggle_task_usecase.dart

import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';

class ToggleTaskUseCase {
  final RoadmapRepository _repository;
  const ToggleTaskUseCase(this._repository);

  Future<void> call({
    required String taskId,
    required int dayNumber,
    required bool isCompleted,
  }) async {
    await _repository.toggleTask(taskId, dayNumber, isCompleted);
  }
}
