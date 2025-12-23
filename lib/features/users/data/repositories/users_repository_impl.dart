import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  UsersRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<WindowsUser>>> getLocalUsers() async {
    try {
      logger.d('Fetching local users from data source');
      final result = await dataSource.getLocalUsers();
      logger.i('Local users fetched successfully: ${result.length} users');
      return Right(result);
    } catch (e) {
      logger.e('Failed to get local users: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleUserStatus(String username, bool enable) async {
    try {
      logger.d('Toggling user "$username" enable: $enable');
      await dataSource.toggleUserStatus(username, enable);
      logger.i('User "$username" toggled successfully');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to toggle user: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetUserPassword(String username, String newPassword) async {
    try {
      logger.d('Resetting password for "$username"');
      await dataSource.resetUserPassword(username, newPassword);
      logger.i('Password reset successfully for "$username"');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to reset password: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
