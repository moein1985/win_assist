import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/error/failure.dart';
import 'package:win_assist/features/logs/data/repositories/logs_repository_impl.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';

class MockDataSource extends Mock implements WindowsServiceDataSource {}

void main() {
  late LogsRepositoryImpl repository;
  late MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    repository = LogsRepositoryImpl(dataSource: mockDataSource, logger: Logger());
  });

  final tLog = LogEntry(index: 1, entryType: LogEntryType.error, source: 'S', message: 'M', timeGenerated: DateTime.now());

  test('returns Right(List<LogEntry>) when data source succeeds', () async {
    when(() => mockDataSource.getSystemLogs()).thenAnswer((_) async => [tLog]);
    final result = await repository.getSystemLogs();
    expect(result.isRight(), true);
    result.fold((l) => fail('expected right'), (r) => expect(r, [tLog]));
  });

  test('returns Left(ServerFailure) when data source throws', () async {
    when(() => mockDataSource.getSystemLogs()).thenThrow(Exception('boom'));
    final result = await repository.getSystemLogs();
    expect(result.isLeft(), true);
    result.fold((l) => expect(l, isA<ServerFailure>()), (r) => fail('expected left'));
  });
}
