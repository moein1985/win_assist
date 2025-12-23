import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class ResetUserPasswordParams {
  final String username;
  final String newPassword;

  ResetUserPasswordParams({required this.username, required this.newPassword});
}

class ResetUserPassword implements UseCase<Unit, ResetUserPasswordParams> {
  final UsersRepository repository;

  ResetUserPassword(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetUserPasswordParams params) async {
    return await repository.resetUserPassword(params.username, params.newPassword);
  }
}
