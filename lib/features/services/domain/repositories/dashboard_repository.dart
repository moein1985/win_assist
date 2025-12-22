import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardInfo>> getDashboardInfo();
}