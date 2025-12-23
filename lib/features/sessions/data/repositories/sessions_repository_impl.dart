import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';
import 'package:win_assist/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  SessionsRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<WindowsSession>>> getRemoteSessions() async {
    try {
      logger.d('Fetching remote sessions from data source');
      final result = await dataSource.getRemoteSessions();
      logger.i('Remote sessions fetched successfully: ${result.length}');
      return Right(result);
    } catch (e) {
      logger.e('Failed to get remote sessions: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> killSession(int sessionId) async {
    try {
      logger.d('Killing session $sessionId');
      await dataSource.killSession(sessionId);
      logger.i('Session $sessionId killed successfully');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to kill session: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
