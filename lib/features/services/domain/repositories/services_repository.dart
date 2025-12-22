import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<ServiceItem>>> getServices();
}