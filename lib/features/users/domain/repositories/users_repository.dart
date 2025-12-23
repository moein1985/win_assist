import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<WindowsUser>>> getLocalUsers();
  Future<Either<Failure, Unit>> toggleUserStatus(String username, bool enable);
  Future<Either<Failure, Unit>> resetUserPassword(String username, String newPassword);
}
