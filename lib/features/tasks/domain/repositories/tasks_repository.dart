import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';

abstract class TasksRepository {
  Future<Either<Failure, List<ScheduledTask>>> getTasks();
  Future<Either<Failure, void>> runTask(String taskName);
  Future<Either<Failure, void>> stopTask(String taskName);
}
