import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class UpdateServiceParams {
  final String serviceName;
  final ServiceAction action;

  UpdateServiceParams({required this.serviceName, required this.action});
}

class UpdateServiceStatus implements UseCase<Unit, UpdateServiceParams> {
  final ServicesRepository repository;

  UpdateServiceStatus(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateServiceParams params) async {
    return await repository.updateServiceStatus(params.serviceName, params.action);
  }
}
