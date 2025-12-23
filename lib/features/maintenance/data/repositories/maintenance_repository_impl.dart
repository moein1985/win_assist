import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  MaintenanceRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, String>> cleanTempFiles() async {
    try {
      logger.d('Cleaning temp files via data source');
      final result = await dataSource.cleanTempFiles();
      logger.i('Clean temp files result: $result');
      return Right(result);
    } catch (e) {
      logger.e('Failed to clean temp files: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> flushDns() async {
    try {
      logger.d('Flushing DNS via data source');
      final result = await dataSource.flushDns();
      logger.i('Flush DNS result: $result');
      return Right(result);
    } catch (e) {
      logger.e('Failed to flush DNS: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> restartServer() async {
    try {
      logger.d('Restarting server via data source');
      await dataSource.restartServer();
      logger.i('Restart command sent');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to restart server: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> shutdownServer() async {
    try {
      logger.d('Shutting down server via data source');
      await dataSource.shutdownServer();
      logger.i('Shutdown command sent');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to shutdown server: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
