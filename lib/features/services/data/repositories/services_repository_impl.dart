import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  ServicesRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<ServiceItem>>> getServices() async {
    try {
      logger.d('Fetching services from data source');
      final result = await dataSource.getServices();
      logger.i('Services fetched successfully: ${result.length} services');
      return Right(result);
    } catch (e) {
      logger.e('Failed to get services: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateServiceStatus(String serviceName, ServiceAction action) async {
    try {
      logger.d('Updating service "$serviceName" action: $action');
      await dataSource.updateServiceStatus(serviceName, action);
      logger.i('Service "$serviceName" updated successfully');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to update service: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 