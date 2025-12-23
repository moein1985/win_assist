import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';
import 'package:win_assist/features/sessions/domain/repositories/sessions_repository.dart';

class GetRemoteSessions implements UseCase<List<WindowsSession>, NoParams> {
  final SessionsRepository repository;

  GetRemoteSessions(this.repository);

  @override
  Future<Either<Failure, List<WindowsSession>>> call(NoParams params) async {
    return await repository.getRemoteSessions();
  }
}
