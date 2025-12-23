import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';

abstract class SessionsRepository {
  Future<Either<Failure, List<WindowsSession>>> getRemoteSessions();
  Future<Either<Failure, Unit>> killSession(int sessionId);
}
