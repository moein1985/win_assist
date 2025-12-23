import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class GetLocalUsers implements UseCase<List<WindowsUser>, NoParams> {
  final UsersRepository repository;

  GetLocalUsers(this.repository);

  @override
  Future<Either<Failure, List<WindowsUser>>> call(NoParams params) async {
    return await repository.getLocalUsers();
  }
}
