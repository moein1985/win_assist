import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';
import 'package:win_assist/features/logs/domain/repositories/logs_repository.dart';
import 'package:win_assist/features/logs/domain/usecases/get_system_logs.dart';

class MockLogsRepository extends Mock implements LogsRepository {}

void main() {
  late GetSystemLogs usecase;
  late MockLogsRepository mockRepository;

  setUp(() {
    mockRepository = MockLogsRepository();
    usecase = GetSystemLogs(mockRepository);
  });

  final tLog = LogEntry(
    index: 1,
    entryType: LogEntryType.error,
    source: 'ServiceX',
    message: 'Something failed',
    timeGenerated: DateTime.parse('2025-12-23T12:34:56'),
  );

  test('should get list of LogEntry from the repository', () async {
    // arrange
    when(() => mockRepository.getSystemLogs())
        .thenAnswer((_) async => Right([tLog]));
    // act
    final result = await usecase(NoParams());
    // assert
    expect(result.isRight(), true);
    result.fold((l) => null, (r) => expect(r, [tLog]));
    verify(() => mockRepository.getSystemLogs()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getSystemLogs())
        .thenAnswer((_) async => Left(ServerFailure(message: 'error')));
    // act
    final result = await usecase(NoParams());
    // assert
    expect(result.isLeft(), true);
    result.fold((l) => expect(l.message, 'error'), (r) => null);
    verify(() => mockRepository.getSystemLogs()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
