import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  DashboardRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, DashboardInfo>> getDashboardInfo() async {
    try {
      logger.d('Fetching dashboard info from data source');
      final result = await dataSource.getDashboardInfo();
      logger.i('Dashboard info fetched successfully');
      return Right(result);
    } catch (e) {
      logger.e('Failed to get dashboard info: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}