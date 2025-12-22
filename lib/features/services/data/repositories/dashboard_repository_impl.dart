import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final WindowsServiceDataSource dataSource;

  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, DashboardInfo>> getDashboardInfo() async {
    try {
      final result = await dataSource.getDashboardInfo();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}