import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/tasks/domain/repositories/tasks_repository.dart';

class RunTask implements UseCase<void, String> {
  final TasksRepository repository;

  RunTask(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.runTask(params);
  }
}
