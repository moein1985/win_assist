import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';
import 'package:win_assist/features/logs/domain/repositories/logs_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class LogsRepositoryImpl implements LogsRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  LogsRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<LogEntry>>> getSystemLogs() async {
    try {
      logger.d('Fetching system logs via data source');
      final result = await dataSource.getSystemLogs();
      logger.i('Fetched ${result.length} log entries');
      return Right(result);
    } catch (e) {
      logger.e('Failed to fetch system logs: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
