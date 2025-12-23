import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';

abstract class LogsRepository {
  Future<Either<Failure, List<LogEntry>>> getSystemLogs();
}
