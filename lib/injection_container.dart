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

// Users feature
import 'package:win_assist/features/users/data/repositories/users_repository_impl.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';
import 'package:win_assist/features/users/domain/usecases/get_local_users.dart';
import 'package:win_assist/features/users/domain/usecases/toggle_user_status.dart';
import 'package:win_assist/features/users/domain/usecases/reset_user_password.dart';
import 'package:win_assist/features/users/presentation/bloc/users_bloc.dart';

// Sessions feature
import 'package:win_assist/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:win_assist/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:win_assist/features/sessions/domain/usecases/get_remote_sessions.dart';
import 'package:win_assist/features/sessions/domain/usecases/kill_session.dart';
import 'package:win_assist/features/sessions/presentation/bloc/sessions_bloc.dart';

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
  // Users repository
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(dataSource: sl(), logger: sl()),
  );
  // Sessions repository
  sl.registerLazySingleton<SessionsRepository>(
    () => SessionsRepositoryImpl(dataSource: sl(), logger: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardInfo(sl()));
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton(() => UpdateServiceStatus(sl()));
  // Users use cases
  sl.registerLazySingleton(() => GetLocalUsers(sl()));
  sl.registerLazySingleton(() => ToggleUserStatus(sl()));
  sl.registerLazySingleton(() => ResetUserPassword(sl()));
  // Sessions use cases
  sl.registerLazySingleton(() => GetRemoteSessions(sl()));
  sl.registerLazySingleton(() => KillSession(sl()));

  // Blocs
  sl.registerFactory(() => DashboardBloc(getDashboardInfo: sl(), logger: sl()));
  sl.registerFactory(() => ServicesBloc(getServices: sl(), updateServiceStatus: sl(), logger: sl()));
  sl.registerFactory(() => UsersBloc(getLocalUsers: sl(), toggleUserStatus: sl(), resetUserPassword: sl(), logger: sl()));
  sl.registerFactory(() => SessionsBloc(getRemoteSessions: sl(), killSession: sl(), logger: sl()));
}