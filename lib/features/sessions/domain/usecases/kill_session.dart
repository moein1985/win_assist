import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/sessions/domain/repositories/sessions_repository.dart';

class KillSessionParams {
  final int sessionId;

  KillSessionParams({required this.sessionId});
}

class KillSession implements UseCase<Unit, KillSessionParams> {
  final SessionsRepository repository;

  KillSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(KillSessionParams params) async {
    return await repository.killSession(params.sessionId);
  }
}
