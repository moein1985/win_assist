import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final WindowsServiceDataSource dataSource;

  ServicesRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ServiceItem>>> getServices() async {
    try {
      final result = await dataSource.getServices();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}