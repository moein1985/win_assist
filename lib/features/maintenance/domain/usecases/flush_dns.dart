import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/maintenance/domain/repositories/maintenance_repository.dart';

class FlushDns implements UseCase<String, NoParams> {
  final MaintenanceRepository repository;

  FlushDns(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.flushDns();
  }
}
