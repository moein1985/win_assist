import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/repositories/dashboard_repository.dart';

class GetDashboardInfo implements UseCase<DashboardInfo, NoParams> {
  final DashboardRepository repository;

  GetDashboardInfo(this.repository);

  @override
  Future<Either<Failure, DashboardInfo>> call(NoParams params) async {
    return await repository.getDashboardInfo();
  }
}