import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/data/repositories/dashboard_repository_impl.dart';
import 'package:win_assist/features/services/data/repositories/services_repository_impl.dart';
import 'package:win_assist/features/services/domain/repositories/dashboard_repository.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';
import 'package:win_assist/features/services/domain/usecases/get_dashboard_info.dart';
import 'package:win_assist/features/services/domain/usecases/get_services.dart';
import 'package:win_assist/features/services/domain/usecases/update_service_status.dart';
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Logger
  sl.registerLazySingleton<Logger>(() => Logger(
    printer: PrettyPrinter(),
  ));

  // Data sources
  sl.registerLazySingleton<WindowsServiceDataSource>(
    () => WindowsServiceDataSourceImpl(logger: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(dataSource: sl(), logger: sl()),
  );
  sl.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(dataSource: sl(), logger: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardInfo(sl()));
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton(() => UpdateServiceStatus(sl()));

  // Blocs
  sl.registerFactory(() => DashboardBloc(getDashboardInfo: sl(), logger: sl()));
  sl.registerFactory(() => ServicesBloc(getServices: sl(), updateServiceStatus: sl(), logger: sl()));
}