import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class GetServices implements UseCase<List<ServiceItem>, NoParams> {
  final ServicesRepository repository;

  GetServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceItem>>> call(NoParams params) async {
    return await repository.getServices();
  }
}