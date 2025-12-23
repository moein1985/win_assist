import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<ServiceItem>>> getServices();
  Future<Either<Failure, Unit>> updateServiceStatus(String serviceName, ServiceAction action);
} 