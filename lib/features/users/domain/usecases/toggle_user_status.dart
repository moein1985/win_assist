import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class ToggleUserStatusParams {
  final String username;
  final bool enable;

  ToggleUserStatusParams({required this.username, required this.enable});
}

class ToggleUserStatus implements UseCase<Unit, ToggleUserStatusParams> {
  final UsersRepository repository;

  ToggleUserStatus(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ToggleUserStatusParams params) async {
    return await repository.toggleUserStatus(params.username, params.enable);
  }
}
