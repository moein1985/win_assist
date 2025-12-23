import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/maintenance/domain/repositories/maintenance_repository.dart';

class ShutdownServer implements UseCase<Unit, NoParams> {
  final MaintenanceRepository repository;

  ShutdownServer(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.shutdownServer();
  }
}
