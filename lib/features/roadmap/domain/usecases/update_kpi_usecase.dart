// lib/features/roadmap/domain/usecases/update_kpi_usecase.dart

import 'package:iron_mind/features/roadmap/domain/repositories/roadmap_repository.dart';

class UpdateKpiUseCase {
  final RoadmapRepository _repository;
  const UpdateKpiUseCase(this._repository);

  Future<void> call({
    int? codeforcesProblems,
    int? ctfMachines,
    int? cyberLabs,
    int? contests,
    int? pompesPR,
    int? gainagePR,
  }) async {
    await _repository.updateKpi(
      codeforcesProblems: codeforcesProblems,
      ctfMachines:        ctfMachines,
      cyberLabs:          cyberLabs,
      contests:           contests,
      pompesPR:           pompesPR,
      gainagePR:          gainagePR,
    );
  }
}
