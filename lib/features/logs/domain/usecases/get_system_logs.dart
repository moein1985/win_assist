import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';
import 'package:win_assist/features/logs/domain/repositories/logs_repository.dart';

class GetSystemLogs implements UseCase<List<LogEntry>, NoParams> {
  final LogsRepository repository;

  GetSystemLogs(this.repository);

  @override
  Future<Either<Failure, List<LogEntry>>> call(NoParams params) async {
    return await repository.getSystemLogs();
  }
}
