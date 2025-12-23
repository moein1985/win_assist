import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:win_assist/screens/tools_screen.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';

class MockLogsBloc extends MockBloc<LogsEvent, LogsState> implements LogsBloc {}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(GetLogsEvent());
    registerFallbackValue(LogsInitial());
  });

  testWidgets('Tapping System Event Logs opens LogsPage', (tester) async {
    // register a Mock LogsBloc in DI so ToolsScreen can acquire it
    final mockBloc = MockLogsBloc();
    when(() => mockBloc.state).thenReturn(LogsInitial());
    whenListen(mockBloc, Stream<LogsState>.fromIterable([LogsInitial()]));
    sl.registerFactory<LogsBloc>(() => mockBloc);

    await tester.pumpWidget(MaterialApp(home: ToolsScreen()));
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
}
