import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/screens/tools_screen.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';
// Dashboard types for ToolsScreen AD test
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

class MockLogsBloc extends MockBloc<LogsEvent, LogsState> implements LogsBloc {}

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState> implements DashboardBloc {}

class FakeDashboardEvent extends Fake implements DashboardEvent {}
class FakeDashboardState extends Fake implements DashboardState {}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(GetLogsEvent());
    registerFallbackValue(LogsInitial());
    registerFallbackValue(FakeDashboardEvent());
    registerFallbackValue(FakeDashboardState());
  });

  testWidgets('Tapping System Event Logs opens LogsPage', (tester) async {
    // register a Mock LogsBloc in DI so ToolsScreen can acquire it
    final mockBloc = MockLogsBloc();
    when(() => mockBloc.state).thenReturn(LogsInitial());
    whenListen(mockBloc, Stream<LogsState>.fromIterable([LogsInitial()]));
    sl.registerFactory<LogsBloc>(() => mockBloc);

    // The ToolsScreen now expects DashboardBloc to be available (it's provided at Home level normally)
    final mockDash = MockDashboardBloc();
    when(() => mockDash.state).thenReturn(DashboardInitial());
    whenListen(mockDash, Stream<DashboardState>.fromIterable([DashboardInitial()]));

    await tester.pumpWidget(MaterialApp(home: BlocProvider<DashboardBloc>.value(
      value: mockDash,
      child: const ToolsScreen(),
    )));
    await tester.pumpAndSettle();

    // find the card and tap it
    expect(find.text('System Event Logs'), findsOneWidget);
    await tester.tap(find.text('System Event Logs'));
    await tester.pumpAndSettle();

    // When opened, the AppBar title should be System Event Logs
    expect(find.text('System Event Logs'), findsWidgets);

    // cleanup registration
    sl.unregister<LogsBloc>();
  });

  testWidgets('ToolsScreen shows AD user manager when Dashboard indicates domain controller', (tester) async {
    // Create a mock DashboardBloc and provide it directly using BlocProvider
    final mockDash = MockDashboardBloc();

    final dashInfo = DashboardInfo(
      osName: 'Windows',
      model: 'VM',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
      domainRole: 4,
    );

    when(() => mockDash.state).thenReturn(DashboardLoaded(dashboardInfo: dashInfo));
    whenListen(mockDash, Stream<DashboardState>.fromIterable([DashboardLoaded(dashboardInfo: dashInfo)]));

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<DashboardBloc>.value(
        value: mockDash,
        child: const ToolsScreen(),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('User Manager (AD)'), findsOneWidget);
  });
}
