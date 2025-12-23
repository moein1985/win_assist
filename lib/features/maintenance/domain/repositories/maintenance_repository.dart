import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, String>> cleanTempFiles();
  Future<Either<Failure, String>> flushDns();
  Future<Either<Failure, Unit>> restartServer();
  Future<Either<Failure, Unit>> shutdownServer();
}
