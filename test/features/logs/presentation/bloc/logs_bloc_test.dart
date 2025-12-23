import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';
import 'package:win_assist/features/logs/domain/usecases/get_system_logs.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';

class MockGetSystemLogs extends Mock implements GetSystemLogs {}

void main() {
  late LogsBloc bloc;
  late MockGetSystemLogs mockGetSystemLogs;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetSystemLogs = MockGetSystemLogs();
    bloc = LogsBloc(getSystemLogs: mockGetSystemLogs, logger: null);
  });

  final tLog = LogEntry(
    index: 1,
    entryType: LogEntryType.warning,
    source: 'Svc',
    message: 'Warned',
    timeGenerated: DateTime.parse('2025-12-23T00:00:00'),
  );

  tearDown(() {
    bloc.close();
  });

  blocTest<LogsBloc, LogsState>(
    'emits [LogsLoading, LogsLoaded] when GetSystemLogs succeeds',
    build: () {
      when(() => mockGetSystemLogs.call(any()))
          .thenAnswer((_) async => Right([tLog]));
      return bloc;
    },
    act: (bloc) => bloc.add(GetLogsEvent()),
    expect: () => [isA<LogsLoading>(), isA<LogsLoaded>()],
    verify: (_) {
      verify(() => mockGetSystemLogs.call(any())).called(1);
    },
  );

  blocTest<LogsBloc, LogsState>(
    'emits [LogsLoading, LogsError] when GetSystemLogs fails',
    build: () {
      when(() => mockGetSystemLogs.call(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'oops')));
      return bloc;
    },
    act: (bloc) => bloc.add(GetLogsEvent()),
    expect: () => [isA<LogsLoading>(), isA<LogsError>()],
    verify: (_) {
      verify(() => mockGetSystemLogs.call(any())).called(1);
    },
  );
}
