import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';
import 'package:win_assist/features/logs/presentation/pages/logs_page.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';

class MockLogsBloc extends MockBloc<LogsEvent, LogsState> implements LogsBloc {}

void main() {
  late MockLogsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(GetLogsEvent());
    registerFallbackValue(LogsInitial());
  });

  setUp(() {
    mockBloc = MockLogsBloc();
  });

  testWidgets('Displays list of logs and opens dialog on tap', (tester) async {
    final tLog = LogEntry(index: 1, entryType: LogEntryType.error, source: 'Svc', message: 'Line1\nLine2', timeGenerated: DateTime.parse('2025-12-23T01:02:03'));

    whenListen(mockBloc, Stream.fromIterable([LogsLoading(), LogsLoaded(logs: [tLog])]), initialState: LogsInitial());

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<LogsBloc>.value(
        value: mockBloc,
        child: const LogsPage(),
      ),
    ));

    await tester.pumpAndSettle();

    // confirm ListTile is shown
    expect(find.textContaining('Svc'), findsOneWidget);
    expect(find.textContaining('#1'), findsOneWidget);

    // tap item and expect dialog with full message
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.text('Line1\nLine2'), findsOneWidget);
    expect(find.textContaining('Time:'), findsOneWidget);
  });
}
