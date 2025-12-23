# ALL_CODE.md

این فایل شامل تمام کدهای پروژه است: **تمام فایل‌های `.dart`** و فایل **`pubspec.yaml`**، برای ارسال به بررسی‌کننده.

---

## فایل‌های گنجانده شده

- `pubspec.yaml`
- `lib/main.dart`
- `lib/injection_container.dart`
- `lib/services/windows_service.dart`
- `lib/core/usecases/usecase.dart`
- `lib/core/error/failure.dart`
- `lib/features/services/data/datasources/windows_service_data_source.dart`
- `lib/features/services/data/repositories/services_repository_impl.dart`
- `lib/features/services/data/repositories/dashboard_repository_impl.dart`
- `lib/features/services/domain/usecases/get_services.dart`
- `lib/features/services/domain/usecases/get_dashboard_info.dart`
- `lib/features/services/domain/usecases/update_service_status.dart`
- `lib/features/services/domain/repositories/services_repository.dart`
- `lib/features/services/domain/repositories/dashboard_repository.dart`
- `lib/features/services/domain/entities/service_item.dart`
- `lib/features/services/domain/entities/service_action.dart`
- `lib/features/services/domain/entities/dashboard_info.dart`
- `lib/features/services/presentation/bloc/services_bloc.dart`
- `lib/features/services/presentation/bloc/dashboard_bloc.dart`
- `lib/features/services/presentation/pages/services_page.dart`
- `lib/features/services/presentation/pages/dashboard_page.dart`
- `lib/features/services/presentation/widgets/ram_card.dart`
- `lib/features/services/presentation/widgets/storage_card.dart`
- `lib/models/dashboard_info.dart`
- `lib/models/service_item.dart`
- `lib/models/server_info.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/tools_screen.dart`
- `lib/features/users/presentation/pages/users_page.dart`
- `lib/features/users/presentation/bloc/users_bloc.dart`
- `lib/features/users/data/repositories/users_repository_impl.dart`
- `lib/features/users/domain/usecases/get_local_users.dart`
- `lib/features/users/domain/usecases/toggle_user_status.dart`
- `lib/features/users/domain/usecases/reset_user_password.dart`
- `lib/features/users/domain/repositories/users_repository.dart`
- `lib/features/users/domain/entities/windows_user.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/services_screen.dart`
- `lib/widgets/ram_card.dart`
- `lib/widgets/storage_card.dart`
- `lib/features/sessions/domain/entities/windows_session.dart`
- `lib/features/sessions/domain/repositories/sessions_repository.dart`
- `lib/features/sessions/domain/usecases/get_remote_sessions.dart`
- `lib/features/sessions/domain/usecases/kill_session.dart`
- `lib/features/sessions/data/repositories/sessions_repository_impl.dart`
- `lib/features/sessions/presentation/bloc/sessions_bloc.dart`
- `lib/features/sessions/presentation/pages/sessions_page.dart`

---


---

## `pubspec.yaml`

```yaml
name: win_assist
description: "A new Flutter project."
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.10.4

dependencies:
  flutter:
    sdk: flutter
  dartssh2: ^2.2.4
  percent_indicator: ^4.2.3
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  get_it: ^7.6.4
  go_router: ^12.1.3
  dartz: ^0.10.1
  equatable: ^2.0.5
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

---

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:win_assist/injection_container.dart' as di;
import 'package:win_assist/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Win Assist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## `lib/injection_container.dart`

```dart
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
}
```

---

## `lib/services/windows_service.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:win_assist/models/dashboard_info.dart';
import 'package:win_assist/models/service_item.dart';

class WindowsService {
  SSHClient? _client;

  bool get isConnected => _client != null && !_client!.isClosed;

  Future<void> connect({
    required String ip,
    required int port,
    required String username,
    required String password,
  }) async {
    if (isConnected) {
      debugPrint('Already connected.');
      return;
    }
    debugPrint('Connecting to $ip:$port...');
    try {
      final socket = await SSHSocket.connect(ip, port, timeout: const Duration(seconds: 15));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      // Wait for the client to be ready
      await _client!.authenticated;
      debugPrint('SSH connection successful.');
    } on TimeoutException {
      debugPrint('Connection timed out.');
      _client = null;
      rethrow;
    } catch (e) {
      debugPrint('Connection failed: $e');
      _client = null;
      rethrow;
    }
  }

  Future<DashboardInfo> getDashboardInfo() async {
    if (!isConnected) {
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''
      $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem;
      $csInfo = Get-CimInstance -ClassName Win32_ComputerSystem;
      $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'";

      $output = @{
          OsName = $osInfo.Caption;
          CsModel = $csInfo.Model;
          CsTotalPhysicalMemory = $csInfo.TotalPhysicalMemory;
          OsFreePhysicalMemoryInBytes = [long]($osInfo.FreePhysicalMemory * 1024);
          DriveC_Free = $diskInfo.FreeSpace;
          DriveC_Total = $diskInfo.Size
      }

      $output | ConvertTo-Json -Compress
    ''';

    debugPrint('Executing getDashboardInfo command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        throw Exception('Received empty response from server for dashboard info.');
      }
      return DashboardInfo.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error getting dashboard info: $e');
      rethrow;
    }
  }

  Future<List<ServiceItem>> getServices() async {
    if (!isConnected) {
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = 'Get-Service | Select-Object ServiceName, DisplayName, Status | ConvertTo-Json -Compress';
    debugPrint('Executing getServices command...');
    try {
      final jsonString = await _execute(command);
       if (jsonString.isEmpty) {
        throw Exception('Received empty response from server for services.');
      }
      // Handle the case where a single JSON object is returned
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [ServiceItem.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ServiceItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting services: $e');
      rethrow;
    }
  }

  Future<String> _execute(String command) async {
    final session = await _client!.execute('powershell -NoProfile -Command "$command"');
    final output = await utf8.decodeStream(session.stdout);
    final error = await utf8.decodeStream(session.stderr);

    if (error.isNotEmpty) {
      throw Exception('PowerShell Error: $error');
    }
    return output.trim();
  }

  void disconnect() {
    if (isConnected) {
      debugPrint('Disconnecting...');
      _client?.close();
      _client = null;
    }
  }
}
```

---

## `lib/core/usecases/usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

---

## `lib/core/error/failure.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
```

---

## `lib/features/services/data/datasources/windows_service_data_source.dart`

```dart
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';

abstract class WindowsServiceDataSource {
  Future<DashboardInfo> getDashboardInfo();
  Future<List<ServiceItem>> getServices();
  Future<void> connect(String ip, int port, String username, String password);
  void disconnect();
  bool get isConnected;

  // Service management
  Future<void> updateServiceStatus(String serviceName, ServiceAction action);

  // User management
  Future<List<WindowsUser>> getLocalUsers();
  Future<void> toggleUserStatus(String username, bool enable);
  Future<void> resetUserPassword(String username, String newPassword);

  // Sessions
  Future<List<WindowsSession>> getRemoteSessions();
  Future<void> killSession(int sessionId);
}

class WindowsServiceDataSourceImpl implements WindowsServiceDataSource {
  final Logger logger;

  WindowsServiceDataSourceImpl({required this.logger});

  SSHClient? _client;

  @override
  bool get isConnected => _client != null && !_client!.isClosed;

  @override
  Future<void> connect(String ip, int port, String username, String password) async {
    if (isConnected) {
      logger.i('Already connected.');
      return;
    }
    logger.i('Connecting to $ip:$port...');
    try {
      final socket = await SSHSocket.connect(ip, port, timeout: const Duration(seconds: 15));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      // Wait for the client to be ready
      await _client!.authenticated;
      logger.i('SSH connection successful.');
    } catch (e) {
      logger.e('Connection failed: $e');
      _client = null;
      rethrow;
    }
  }

  @override
  Future<DashboardInfo> getDashboardInfo() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''$ProgressPreference = 'SilentlyContinue'; $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem; $csInfo = Get-CimInstance -ClassName Win32_ComputerSystem; $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"; @{ OsName = if ($osInfo.Caption) { $osInfo.Caption } else { "N/A" }; CsModel = if ($csInfo.Model) { $csInfo.Model } else { "N/A" }; CsTotalPhysicalMemory = if ($csInfo.TotalPhysicalMemory) { $csInfo.TotalPhysicalMemory } else { 0 }; OsFreePhysicalMemoryInBytes = if ($osInfo.FreePhysicalMemory) { [long]($osInfo.FreePhysicalMemory * 1024) } else { 0 }; DriveC_Free = if ($diskInfo.FreeSpace) { $diskInfo.FreeSpace } else { 0 }; DriveC_Total = if ($diskInfo.Size) { $diskInfo.Size } else { 0 } } | ConvertTo-Json -Compress''';

    logger.d('Executing getDashboardInfo command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        logger.e('Received empty response from server for dashboard info.');
        throw Exception('Received empty response from server for dashboard info.');
      }
      return DashboardInfo.fromJson(jsonDecode(jsonString));
    } catch (e) {
      logger.e('Error getting dashboard info: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceItem>> getServices() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command =
        r'''$ProgressPreference = 'SilentlyContinue'; Get-Service | Select-Object ServiceName, DisplayName, Status | ConvertTo-Json -Compress''';
    logger.d('Executing getServices command...');
    try {
      final jsonString = await _execute(command);
       if (jsonString.isEmpty) {
        logger.e('Received empty response from server for services.');
        throw Exception('Received empty response from server for services.');
      }
      // Handle the case where a single JSON object is returned
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [ServiceItem.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ServiceItem.fromJson(json)).toList();
    } catch (e) {
      logger.e('Error getting services: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateServiceStatus(String serviceName, ServiceAction action) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    String command;
    switch (action) {
      case ServiceAction.start:
        command = "Start-Service -Name '$serviceName'";
        break;
      case ServiceAction.stop:
        command = "Stop-Service -Name '$serviceName' -Force";
        break;
      case ServiceAction.restart:
        command = "Restart-Service -Name '$serviceName' -Force";
        break;
    }

    logger.d('Executing service action command: $command');
    try {
      final output = await _execute(command);
      logger.i('Service action completed. Output: $output');
    } catch (e) {
      logger.e('Error updating service status: $e');
      rethrow;
    }
  }

  @override
  Future<List<WindowsUser>> getLocalUsers() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''Get-LocalUser | Select-Object Name,Enabled,LastLogon,Description | ConvertTo-Json -Compress''';
    logger.d('Executing getLocalUsers command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        logger.e('Received empty response from server for local users.');
        throw Exception('Received empty response from server for local users.');
      }

      // Handle single object or list
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [WindowsUser.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WindowsUser.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      logger.e('Error getting local users: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleUserStatus(String username, bool enable) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    final command = enable
        ? "Enable-LocalUser -Name '$username'"
        : "Disable-LocalUser -Name '$username'";

    logger.d('Executing toggleUserStatus command: $command');
    try {
      final output = await _execute(command);
      logger.i('Toggle user status completed. Output: $output');
    } catch (e) {
      logger.e('Error toggling user status: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetUserPassword(String username, String newPassword) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    final command = '\$secPass = ConvertTo-SecureString "${newPassword.replaceAll('"', '\\"')}" -AsPlainText -Force; Set-LocalUser -Name "${username.replaceAll('"', '\\"')}" -Password \$secPass';

    logger.d('Executing resetUserPassword command for $username');
    try {
      final output = await _execute(command);
      logger.i('Reset password completed. Output: $output');
    } catch (e) {
      logger.e('Error resetting user password: $e');
      rethrow;
    }
  }

  Future<String> _execute(String command) async {
    logger.d('Executing command: $command');
    // PowerShell's -EncodedCommand expects a Base64-encoded string of a UTF-16LE command.
    final List<int> commandBytes = [];
    for (final codeUnit in command.codeUnits) {
      commandBytes.add(codeUnit & 0xFF);
      commandBytes.add(codeUnit >> 8);
    }
    final base64Command = base64.encode(commandBytes);

    final session = await _client!.execute('powershell -NoProfile -EncodedCommand $base64Command');
    final output = await utf8.decodeStream(session.stdout);
    final error = await utf8.decodeStream(session.stderr);

    if (error.isNotEmpty) {
      logger.e('PowerShell Error: $error');
      throw Exception('PowerShell Error: $error');
    }
    return output.trim();
  }

  @override
  void disconnect() {
    if (isConnected) {
      logger.i('Disconnecting...');
      _client?.close();
      _client = null;
    }
  }
}
```

---

## `lib/features/services/data/repositories/services_repository_impl.dart`

```dart
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
```

---

## `lib/features/services/data/repositories/dashboard_repository_impl.dart`

```dart
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
```

---

## `lib/features/services/domain/usecases/get_services.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class GetServices implements UseCase<List<ServiceItem>, NoParams> {
  final ServicesRepository repository;

  GetServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceItem>>> call(NoParams params) async {
    return await repository.getServices();
  }
}
```

---

## `lib/features/services/domain/usecases/update_service_status.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';
import 'package:win_assist/features/services/domain/repositories/services_repository.dart';

class UpdateServiceParams {
  final String serviceName;
  final ServiceAction action;

  UpdateServiceParams({required this.serviceName, required this.action});
}

class UpdateServiceStatus implements UseCase<Unit, UpdateServiceParams> {
  final ServicesRepository repository;

  UpdateServiceStatus(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateServiceParams params) async {
    return await repository.updateServiceStatus(params.serviceName, params.action);
  }
}
```

---

## `lib/features/services/domain/usecases/get_dashboard_info.dart`

```dart
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
```

---

## `lib/features/services/domain/repositories/services_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<ServiceItem>>> getServices();
  Future<Either<Failure, Unit>> updateServiceStatus(String serviceName, ServiceAction action);
}
```

---

## `lib/features/services/domain/repositories/dashboard_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardInfo>> getDashboardInfo();
}
```

---

## `lib/features/services/domain/entities/service_item.dart`

```dart
enum ServiceStatus { running, stopped, unknown }

class ServiceItem {
  final String name;
  final String displayName;
  final ServiceStatus status;

  ServiceItem({
    required this.name,
    required this.displayName,
    required this.status,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    ServiceStatus currentStatus;
    switch (json['Status']) {
      case 'Running':
        currentStatus = ServiceStatus.running;
        break;
      case 'Stopped':
        currentStatus = ServiceStatus.stopped;
        break;
      default:
        currentStatus = ServiceStatus.unknown;
    }

    return ServiceItem(
      name: json['ServiceName'] ?? 'N/A',
      displayName: json['DisplayName'] ?? 'N/A',
      status: currentStatus,
    );
  }
}
```

---

## `lib/features/services/domain/entities/service_action.dart`

```dart
enum ServiceAction { start, stop, restart }
```


---

## `lib/features/services/domain/entities/dashboard_info.dart`

```dart
import 'dart:math';

class DashboardInfo {
  final String osName;
  final String model;
  final double totalRamInGB;
  final double freeRamInGB;
  final double ramUsagePercentage;
  final double totalStorageInGB;
  final double freeStorageInGB;
  final double storageUsagePercentage;

  DashboardInfo({
    required this.osName,
    required this.model,
    required this.totalRamInGB,
    required this.freeRamInGB,
    required this.ramUsagePercentage,
    required this.totalStorageInGB,
    required this.freeStorageInGB,
    required this.storageUsagePercentage,
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    final totalRamBytes = (json['CsTotalPhysicalMemory'] as num?)?.toDouble() ?? 0.0;
    final freeRamBytes = (json['OsFreePhysicalMemoryInBytes'] as num?)?.toDouble() ?? 0.0;

    // Drive info is in Bytes
    final totalStorageBytes = (json['DriveC_Total'] as num?)?.toDouble() ?? 0.0;
    final freeStorageBytes = (json['DriveC_Free'] as num?)?.toDouble() ?? 0.0;

    // Conversion factor
    const bytesInGB = 1024 * 1024 * 1024;

    final totalRamGB = totalRamBytes / bytesInGB;
    final freeRamGB = freeRamBytes / bytesInGB;
    final usedRamGB = max(0, totalRamGB - freeRamGB);

    final totalStorageGB = totalStorageBytes / bytesInGB;
    final freeStorageGB = freeStorageBytes / bytesInGB;
    final usedStorageGB = max(0, totalStorageGB - freeStorageGB);

    return DashboardInfo(
      osName: json['OsName'] ?? 'N/A',
      model: json['CsModel'] ?? 'N/A',
      totalRamInGB: totalRamGB,
      freeRamInGB: freeRamGB,
      ramUsagePercentage: totalRamGB > 0 ? (usedRamGB / totalRamGB) : 0,
      totalStorageInGB: totalStorageGB,
      freeStorageInGB: freeStorageGB,
      storageUsagePercentage: totalStorageGB > 0 ? (usedStorageGB / totalStorageGB) : 0,
    );
  }

  // Helper for creating a loading/initial state
  factory DashboardInfo.initial() {
    return DashboardInfo(
      osName: 'Loading...',
      model: 'N/A',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
    );
  }
}
```

---

## `lib/features/services/presentation/bloc/services_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/usecases/get_services.dart';
import 'package:win_assist/features/services/domain/usecases/update_service_status.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

class GetServicesEvent extends ServicesEvent {}

class UpdateServiceEvent extends ServicesEvent {
  final String serviceName;
  final ServiceAction action;

  const UpdateServiceEvent({required this.serviceName, required this.action});

  @override
  List<Object> get props => [serviceName, action];
}

abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceItem> services;

  const ServicesLoaded({required this.services});

  @override
  List<Object> get props => [services];
}

class ServicesActionInProgress extends ServicesState {
  final String serviceName;

  const ServicesActionInProgress({required this.serviceName});

  @override
  List<Object> get props => [serviceName];
}

class ServicesActionSuccess extends ServicesState {
  final String message;

  const ServicesActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ServicesError extends ServicesState {
  final String message;

  const ServicesError({required this.message});

  @override
  List<Object> get props => [message];
}

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices getServices;
  final UpdateServiceStatus updateServiceStatus;
  final Logger logger;

  ServicesBloc({required this.getServices, required this.updateServiceStatus, required Logger? logger})
      : logger = logger ?? Logger(),
        super(ServicesInitial()) {
    on<GetServicesEvent>(_onGetServices);
    on<UpdateServiceEvent>(_onUpdateService);
  }

  Future<void> _onGetServices(
    GetServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    logger.d('ServicesBloc: Fetching services');
    emit(ServicesLoading());
    final result = await getServices(NoParams());
    result.fold(
      (failure) {
        logger.e('ServicesBloc: Error fetching services: ${failure.message}');
        emit(ServicesError(message: failure.message));
      },
      (services) {
        logger.i('ServicesBloc: Services loaded successfully: ${services.length} services');
        emit(ServicesLoaded(services: services));
      },
    );
  }

  Future<void> _onUpdateService(
    UpdateServiceEvent event,
    Emitter<ServicesState> emit,
  ) async {
    logger.d('ServicesBloc: Updating service ${event.serviceName} action: ${event.action}');
    emit(ServicesActionInProgress(serviceName: event.serviceName));

    final result = await updateServiceStatus(UpdateServiceParams(serviceName: event.serviceName, action: event.action));
    result.fold(
      (failure) {
        logger.e('ServicesBloc: Error updating service: ${failure.message}');
        emit(ServicesError(message: failure.message));
      },
      (_) {
        logger.i('ServicesBloc: Service updated successfully');
        emit(ServicesActionSuccess(message: 'Service ${event.serviceName} ${event.action.toString().split('.').last} successfully'));
        add(GetServicesEvent());
      },
    );
  }
}
```

---

## `lib/features/services/presentation/bloc/dashboard_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/usecases/get_dashboard_info.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class GetDashboardInfoEvent extends DashboardEvent {}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardInfo dashboardInfo;

  const DashboardLoaded({required this.dashboardInfo});

  @override
  List<Object> get props => [dashboardInfo];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardInfo getDashboardInfo;
  final Logger logger;

  DashboardBloc({required this.getDashboardInfo, required Logger? logger})
      : logger = logger ?? Logger(),
        super(DashboardInitial()) {
    on<GetDashboardInfoEvent>(_onGetDashboardInfo);
  }

  Future<void> _onGetDashboardInfo(
    GetDashboardInfoEvent event,
    Emitter<DashboardState> emit,
  ) async {
    logger.d('DashboardBloc: Fetching dashboard info');
    emit(DashboardLoading());
    final result = await getDashboardInfo(NoParams());
    result.fold(
      (failure) {
        logger.e('DashboardBloc: Error fetching dashboard info: ${failure.message}');
        emit(DashboardError(message: failure.message));
      },
      (dashboardInfo) {
        logger.i('DashboardBloc: Dashboard info loaded successfully');
        emit(DashboardLoaded(dashboardInfo: dashboardInfo));
      },
    );
  }
}
```

---

## `lib/features/services/presentation/pages/services_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state is ServicesActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ServicesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServicesError && !(state is ServicesActionSuccess)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ServicesBloc>().add(GetServicesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ServicesLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return const Center(child: Text('No services found.'));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<ServicesBloc>().add(GetServicesEvent()),
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final statusColor = service.status == ServiceStatus.running ? Colors.green : Colors.red;
                  final statusText = service.status.toString().split('.').last;

                  final isUpdating = state is ServicesActionInProgress && (state as ServicesActionInProgress).serviceName == service.name;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(service.displayName),
                      subtitle: Text(service.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: statusColor, size: 12),
                          const SizedBox(width: 8),
                          Text(statusText),
                          PopupMenuButton<ServiceAction>(
                            onSelected: (action) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Performing ${action.toString().split('.').last} on ${service.displayName}...')));
                              context.read<ServicesBloc>().add(UpdateServiceEvent(serviceName: service.name, action: action));
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.start,
                                enabled: service.status != ServiceStatus.running && !isUpdating,
                                child: const Text('Start'),
                              ),
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.stop,
                                enabled: service.status != ServiceStatus.stopped && !isUpdating,
                                child: const Text('Stop'),
                              ),
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.restart,
                                enabled: !isUpdating,
                                child: const Text('Restart'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Welcome to Services'));
        },
      ),
    );
  }
}
```

---

## `lib/features/services/presentation/pages/dashboard_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/presentation/widgets/ram_card.dart';
import 'package:win_assist/features/services/presentation/widgets/storage_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardError) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardBloc>().add(GetDashboardInfoEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is DashboardLoaded) {
          final info = state.dashboardInfo;
          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardBloc>().add(GetDashboardInfoEvent()),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('OS: ${info.osName}'),
                Text('Model: ${info.model}'),
                const SizedBox(height: 24),
                RamCard(info: info),
                const SizedBox(height: 16),
                StorageCard(info: info),
              ],
            ),
          );
        }
        return const Center(child: Text('Welcome to Dashboard'));
      },
    );
  }
}
```

---

## `lib/features/services/presentation/widgets/ram_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

class RamCard extends StatelessWidget {
  final DashboardInfo info;

  const RamCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedRam = info.totalRamInGB - info.freeRamInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: info.ramUsagePercentage,
              center: Text(
                '${(info.ramUsagePercentage * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RAM Usage',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${usedRam.toStringAsFixed(2)} GB / ${info.totalRamInGB.toStringAsFixed(2)} GB',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## `lib/features/services/presentation/widgets/storage_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

class StorageCard extends StatelessWidget {
  final DashboardInfo info;

  const StorageCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final usedGB = info.totalStorageInGB - info.freeStorageInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage (Drive C)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: info.storageUsagePercentage,
              lineHeight: 20,
              center: Text(
                '${(info.storageUsagePercentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 16),
            Text(
              '${usedGB.toStringAsFixed(2)} GB Used of ${info.totalStorageInGB.toStringAsFixed(2)} GB',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## `lib/models/dashboard_info.dart`

```dart
import 'dart:math';

class DashboardInfo {
  final String osName;
  final String model;
  final double totalRamInGB;
  final double freeRamInGB;
  final double ramUsagePercentage;
  final double totalStorageInGB;
  final double freeStorageInGB;
  final double storageUsagePercentage;

  DashboardInfo({
    required this.osName,
    required this.model,
    required this.totalRamInGB,
    required this.freeRamInGB,
    required this.ramUsagePercentage,
    required this.totalStorageInGB,
    required this.freeStorageInGB,
    required this.storageUsagePercentage,
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    final totalRamBytes = (json['CsTotalPhysicalMemory'] as num?)?.toDouble() ?? 0.0;
    final freeRamBytes = (json['OsFreePhysicalMemoryInBytes'] as num?)?.toDouble() ?? 0.0;

    // Drive info is in Bytes
    final totalStorageBytes = (json['DriveC_Total'] as num?)?.toDouble() ?? 0.0;
    final freeStorageBytes = (json['DriveC_Free'] as num?)?.toDouble() ?? 0.0;

    // Conversion factor
    const bytesInGB = 1024 * 1024 * 1024;

    final totalRamGB = totalRamBytes / bytesInGB;
    final freeRamGB = freeRamBytes / bytesInGB;
    final usedRamGB = max(0, totalRamGB - freeRamGB);

    final totalStorageGB = totalStorageBytes / bytesInGB;
    final freeStorageGB = freeStorageBytes / bytesInGB;
    final usedStorageGB = max(0, totalStorageGB - freeStorageGB);

    return DashboardInfo(
      osName: json['OsName'] ?? 'N/A',
      model: json['CsModel'] ?? 'N/A',
      totalRamInGB: totalRamGB,
      freeRamInGB: freeRamGB,
      ramUsagePercentage: totalRamGB > 0 ? (usedRamGB / totalRamGB) : 0,
      totalStorageInGB: totalStorageGB,
      freeStorageInGB: freeStorageGB,
      storageUsagePercentage: totalStorageGB > 0 ? (usedStorageGB / totalStorageGB) : 0,
    );
  }

  // Helper for creating a loading/initial state
  factory DashboardInfo.initial() {
    return DashboardInfo(
      osName: 'Loading...',
      model: 'N/A',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
    );
  }
}
```

---

## `lib/models/service_item.dart`

```dart
enum ServiceStatus { running, stopped, unknown }

class ServiceItem {
  final String name;
  final String displayName;
  final ServiceStatus status;

  ServiceItem({
    required this.name,
    required this.displayName,
    required this.status,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    ServiceStatus currentStatus;
    switch (json['Status']) {
      case 'Running':
        currentStatus = ServiceStatus.running;
        break;
      case 'Stopped':
        currentStatus = ServiceStatus.stopped;
        break;
      default:
        currentStatus = ServiceStatus.unknown;
    }

    return ServiceItem(
      name: json['ServiceName'] ?? 'N/A',
      displayName: json['DisplayName'] ?? 'N/A',
      status: currentStatus,
    );
  }
}
```

---

## `lib/models/server_info.dart`

```dart
import 'dart:convert';

ServerInfo serverInfoFromJson(String str) => ServerInfo.fromJson(json.decode(str));

String serverInfoToJson(ServerInfo data) => json.encode(data.toJson());

class ServerInfo {
    final String osName;
    final String csModel;
    final int csTotalPhysicalMemory;
    final int osFreePhysicalMemory;
    final int csNumberOfLogicalProcessors;
    final OsUptime osUptime;

    ServerInfo({
        required this.osName,
        required this.csModel,
        required this.csTotalPhysicalMemory,
        required this.osFreePhysicalMemory,
        required this.csNumberOfLogicalProcessors,
        required this.osUptime,
    });

    factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
        osName: json["OsName"],
        csModel: json["CsModel"],
        csTotalPhysicalMemory: json["CsTotalPhysicalMemory"],
        osFreePhysicalMemory: json["OsFreePhysicalMemory"],
        csNumberOfLogicalProcessors: json["CsNumberOfLogicalProcessors"],
        osUptime: OsUptime.fromJson(json["OsUptime"]),
    );

    Map<String, dynamic> toJson() => {
        "OsName": osName,
        "CsModel": csModel,
        "CsTotalPhysicalMemory": csTotalPhysicalMemory,
        "OsFreePhysicalMemory": osFreePhysicalMemory,
        "CsNumberOfLogicalProcessors": csNumberOfLogicalProcessors,
        "OsUptime": osUptime.toJson(),
    };
}

class OsUptime {
    final int ticks;
    final int days;
    final int hours;
    final int minutes;
    final int seconds;
    final int milliseconds;
    final double totalDays;
    final double totalHours;
    final double totalMinutes;
    final double totalSeconds;
    final double totalMilliseconds;

    OsUptime({
        required this.ticks,
        required this.days,
        required this.hours,
        required this.minutes,
        required this.seconds,
        required this.milliseconds,
        required this.totalDays,
        required this.totalHours,
        required this.totalMinutes,
        required this.totalSeconds,
        required this.totalMilliseconds,
    });

    factory OsUptime.fromJson(Map<String, dynamic> json) => OsUptime(
        ticks: json["Ticks"],
        days: json["Days"],
        hours: json["Hours"],
        minutes: json["Minutes"],
        seconds: json["Seconds"],
        milliseconds: json["Milliseconds"],
        totalDays: json["TotalDays"]?.toDouble(),
        totalHours: json["TotalHours"]?.toDouble(),
        totalMinutes: json["TotalMinutes"]?.toDouble(),
        totalSeconds: json["TotalSeconds"]?.toDouble(),
        totalMilliseconds: json["TotalMilliseconds"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "Ticks": ticks,
        "Days": days,
        "Hours": hours,
        "Minutes": minutes,
        "Seconds": seconds,
        "Milliseconds": milliseconds,
        "TotalDays": totalDays,
        "TotalHours": totalHours,
        "TotalMinutes": totalMinutes,
        "TotalSeconds": totalSeconds,
        "TotalMilliseconds": totalMilliseconds,
    };
}
```

---

## `lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/injection_container.dart' as di;
import 'package:win_assist/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController(text: '192.168.85.97');
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final Logger logger = di.sl<Logger>();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dataSource = di.sl<WindowsServiceDataSource>();
    try {
      logger.i('Attempting to connect to server: ${_ipController.text}');
      await dataSource.connect(
        _ipController.text,
        22,
        _userController.text,
        _passController.text,
      );
      logger.i('Connection successful, navigating to home screen');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(dataSource: dataSource),
          ),
        );
      }
    } catch (e) {
      logger.e('Login failed: $e');
      setState(() {
        _errorMessage = 'Failed to connect: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Server'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _ipController,
                  decoration: const InputDecoration(labelText: 'Server IP'),
                  validator: (value) => value!.isEmpty ? 'Please enter an IP address' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Connect'),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## `lib/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';
import 'package:win_assist/features/services/presentation/pages/dashboard_page.dart';
import 'package:win_assist/features/services/presentation/pages/services_page.dart';
import 'package:win_assist/screens/tools_screen.dart';
import 'package:win_assist/injection_container.dart' as di;

class HomeScreen extends StatefulWidget {
  final WindowsServiceDataSource dataSource;

  const HomeScreen({super.key, required this.dataSource});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider<DashboardBloc>(
        create: (context) => di.sl<DashboardBloc>()..add(GetDashboardInfoEvent()),
        child: const DashboardPage(),
      ),
      BlocProvider<ServicesBloc>(
        create: (context) => di.sl<ServicesBloc>()..add(GetServicesEvent()),
        child: const ServicesPage(),
      ),
      // Tools tab (contains Local Users Manager)
      const ToolsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    widget.dataSource.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win Assist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Tools',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
```

---

## `lib/screens/dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:win_assist/models/dashboard_info.dart';
import 'package:win_assist/services/windows_service.dart';
import 'package:win_assist/widgets/ram_card.dart';
import 'package:win_assist/widgets/storage_card.dart';

class DashboardScreen extends StatefulWidget {
  final WindowsService service;

  const DashboardScreen({super.key, required this.service});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardInfo> _dashboardInfoFuture;

  @override
  void initState() {
    super.initState();
    _dashboardInfoFuture = _fetchDashboardInfo();
  }

  Future<DashboardInfo> _fetchDashboardInfo() {
    return widget.service.getDashboardInfo();
  }

  void _refresh() {
    setState(() {
      _dashboardInfoFuture = _fetchDashboardInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardInfo>(
      future: _dashboardInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error fetching data: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final info = snapshot.data ?? DashboardInfo.initial();

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('OS: ${info.osName}'),
              Text('Model: ${info.model}'),
              const SizedBox(height: 24),
              RamCard(info: info),
              const SizedBox(height: 16),
              StorageCard(info: info),
            ],
          ),
        );
      },
    );
  }
}
```

---

## `lib/screens/services_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:win_assist/models/service_item.dart';
import 'package:win_assist/services/windows_service.dart';

class ServicesScreen extends StatefulWidget {
  final WindowsService service;

  const ServicesScreen({super.key, required this.service});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Future<List<ServiceItem>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _fetchServices();
  }

  Future<List<ServiceItem>> _fetchServices() {
    return widget.service.getServices();
  }

  Future<void> _refresh() async {
    setState(() {
      _servicesFuture = _fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceItem>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error fetching services: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return const Center(child: Text('No services found.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final statusColor = service.status == ServiceStatus.running ? Colors.green : Colors.red;
              final statusText = service.status.toString().split('.').last;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(service.displayName),
                  subtitle: Text(service.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: statusColor, size: 12),
                      const SizedBox(width: 8),
                      Text(statusText),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

---

## `lib/widgets/ram_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:win_assist/models/dashboard_info.dart';

class RamCard extends StatelessWidget {
  final DashboardInfo info;

  const RamCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedRam = info.totalRamInGB - info.freeRamInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: info.ramUsagePercentage,
              center: Text(
                '${(info.ramUsagePercentage * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RAM Usage',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${usedRam.toStringAsFixed(2)} GB / ${info.totalRamInGB.toStringAsFixed(2)} GB',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## `lib/widgets/storage_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../models/dashboard_info.dart';

class StorageCard extends StatelessWidget {
  final DashboardInfo info;

  const StorageCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final usedGB = info.totalStorageInGB - info.freeStorageInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage (Drive C)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: info.storageUsagePercentage,
              lineHeight: 20,
              center: Text(
                '${(info.storageUsagePercentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 16),
            Text(
              '${usedGB.toStringAsFixed(2)} GB Used of ${info.totalStorageInGB.toStringAsFixed(2)} GB',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## `lib/features/users/domain/entities/windows_user.dart`

```dart
class WindowsUser {
  final String name;
  final bool isEnabled;
  final String? lastLogon;
  final String? description;

  WindowsUser({
    required this.name,
    required this.isEnabled,
    this.lastLogon,
    this.description,
  });

  factory WindowsUser.fromJson(Map<String, dynamic> json) {
    return WindowsUser(
      name: json['Name'] ?? 'N/A',
      isEnabled: json['Enabled'] == true || json['Enabled'] == 'True',
      lastLogon: json['LastLogon']?.toString(),
      description: json['Description']?.toString(),
    );
  }
}
```

---

## `lib/features/users/domain/repositories/users_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<WindowsUser>>> getLocalUsers();
  Future<Either<Failure, Unit>> toggleUserStatus(String username, bool enable);
  Future<Either<Failure, Unit>> resetUserPassword(String username, String newPassword);
}
```

---

## `lib/features/users/domain/usecases/get_local_users.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class GetLocalUsers implements UseCase<List<WindowsUser>, NoParams> {
  final UsersRepository repository;

  GetLocalUsers(this.repository);

  @override
  Future<Either<Failure, List<WindowsUser>>> call(NoParams params) async {
    return await repository.getLocalUsers();
  }
}
```

---

## `lib/features/users/domain/usecases/toggle_user_status.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class ToggleUserStatusParams {
  final String username;
  final bool enable;

  ToggleUserStatusParams({required this.username, required this.enable});
}

class ToggleUserStatus implements UseCase<Unit, ToggleUserStatusParams> {
  final UsersRepository repository;

  ToggleUserStatus(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ToggleUserStatusParams params) async {
    return await repository.toggleUserStatus(params.username, params.enable);
  }
}
```

---

## `lib/features/users/domain/usecases/reset_user_password.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';

class ResetUserPasswordParams {
  final String username;
  final String newPassword;

  ResetUserPasswordParams({required this.username, required this.newPassword});
}

class ResetUserPassword implements UseCase<Unit, ResetUserPasswordParams> {
  final UsersRepository repository;

  ResetUserPassword(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetUserPasswordParams params) async {
    return await repository.resetUserPassword(params.username, params.newPassword);
  }
}
```

---

## `lib/features/users/data/repositories/users_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/repositories/users_repository.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final WindowsServiceDataSource dataSource;
  final Logger logger;

  UsersRepositoryImpl({required this.dataSource, required this.logger});

  @override
  Future<Either<Failure, List<WindowsUser>>> getLocalUsers() async {
    try {
      logger.d('Fetching local users from data source');
      final result = await dataSource.getLocalUsers();
      logger.i('Local users fetched successfully: ${result.length} users');
      return Right(result);
    } catch (e) {
      logger.e('Failed to get local users: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleUserStatus(String username, bool enable) async {
    try {
      logger.d('Toggling user "$username" enable: $enable');
      await dataSource.toggleUserStatus(username, enable);
      logger.i('User "$username" toggled successfully');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to toggle user: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetUserPassword(String username, String newPassword) async {
    try {
      logger.d('Resetting password for "$username"');
      await dataSource.resetUserPassword(username, newPassword);
      logger.i('Password reset successfully for "$username"');
      return Right(unit);
    } catch (e) {
      logger.e('Failed to reset password: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## `lib/features/users/presentation/bloc/users_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/usecases/get_local_users.dart';
import 'package:win_assist/features/users/domain/usecases/toggle_user_status.dart';
import 'package:win_assist/features/users/domain/usecases/reset_user_password.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class GetUsersEvent extends UsersEvent {}

class ToggleUserStatusEvent extends UsersEvent {
  final String username;
  final bool enable;

  const ToggleUserStatusEvent({required this.username, required this.enable});

  @override
  List<Object?> get props => [username, enable];
}

class ResetUserPasswordEvent extends UsersEvent {
  final String username;
  final String newPassword;

  const ResetUserPasswordEvent({required this.username, required this.newPassword});

  @override
  List<Object?> get props => [username, newPassword];
}

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<WindowsUser> users;

  const UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UsersActionInProgress extends UsersState {
  final String username;

  const UsersActionInProgress({required this.username});

  @override
  List<Object?> get props => [username];
}

class UsersActionSuccess extends UsersState {
  final String message;

  const UsersActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersError extends UsersState {
  final String message;

  const UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetLocalUsers getLocalUsers;
  final ToggleUserStatus toggleUserStatus;
  final ResetUserPassword resetUserPassword;
  final Logger logger;

  UsersBloc({
    required this.getLocalUsers,
    required this.toggleUserStatus,
    required this.resetUserPassword,
    required Logger? logger,
  })  : logger = logger ?? Logger(),
        super(UsersInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
    on<ResetUserPasswordEvent>(_onResetUserPassword);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Fetching local users');
    emit(UsersLoading());
    final result = await getLocalUsers(NoParams());
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error fetching users: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (users) {
        logger.i('UsersBloc: Users loaded: ${users.length}');
        emit(UsersLoaded(users: users));
      },
    );
  }

  Future<void> _onToggleUserStatus(ToggleUserStatusEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Toggling user ${event.username} -> ${event.enable}');
    emit(UsersActionInProgress(username: event.username));
    final result = await toggleUserStatus(ToggleUserStatusParams(username: event.username, enable: event.enable));
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error toggling user: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (_) {
        logger.i('UsersBloc: Toggled user successfully');
        emit(UsersActionSuccess(message: 'User ${event.username} ${event.enable ? 'enabled' : 'disabled'} successfully'));
        add(GetUsersEvent());
      },
    );
  }

  Future<void> _onResetUserPassword(ResetUserPasswordEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Resetting password for ${event.username}');
    emit(UsersActionInProgress(username: event.username));
    final result = await resetUserPassword(ResetUserPasswordParams(username: event.username, newPassword: event.newPassword));
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error resetting password: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (_) {
        logger.i('UsersBloc: Password reset successfully');
        emit(UsersActionSuccess(message: 'Password reset for ${event.username}'));
        add(GetUsersEvent());
      },
    );
  }
}
```


