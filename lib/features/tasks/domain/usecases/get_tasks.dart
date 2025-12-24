import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';
import 'package:win_assist/features/tasks/domain/repositories/tasks_repository.dart';

class GetTasks implements UseCase<List<ScheduledTask>, NoParams> {
  final TasksRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<ScheduledTask>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
