import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';
import 'package:win_assist/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class TasksRepositoryImpl implements TasksRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  TasksRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<ScheduledTask>>> getTasks() async {
    try {
      final tasks = await dataSource.getScheduledTasks();
      return Right(tasks);
    } catch (e) {
      logger.e('Error in getTasks repository impl: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> runTask(String taskName) async {
    try {
      await dataSource.runScheduledTask(taskName);
      return const Right(null);
    } catch (e) {
      logger.e('Error in runTask repository impl: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopTask(String taskName) async {
    try {
      await dataSource.stopScheduledTask(taskName);
      return const Right(null);
    } catch (e) {
      logger.e('Error in stopTask repository impl: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
