import 'package:flutter_test/flutter_test.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';

void main() {
  test('parses EntryType as numeric int (1 => Error, 2 => Warning)', () {
    final jsonError = {'Index': 10, 'EntryType': 1, 'Source': 'S', 'Message': 'M', 'TimeGenerated': '2025-12-23T10:00:00'};
    final e1 = LogEntry.fromJson(jsonError);
    expect(e1.entryType, LogEntryType.error);
    expect(e1.index, 10);

    final jsonWarn = {'Index': 11, 'EntryType': 2, 'Source': 'S2', 'Message': 'M2', 'TimeGenerated': '2025-12-23T11:00:00'};
    final e2 = LogEntry.fromJson(jsonWarn);
    expect(e2.entryType, LogEntryType.warning);
    expect(e2.index, 11);
  });

  test('parses EntryType as string ("Error" / "Warning")', () {
    final json = {'Index': 5, 'EntryType': 'Error', 'Source': 'Src', 'Message': 'Msg', 'TimeGenerated': '2025-12-23T12:00:00'};
    final e = LogEntry.fromJson(json);
    expect(e.entryType, LogEntryType.error);
    expect(e.source, 'Src');
  });

  test('parses EntryType as numeric string', () {
    final json = {'Index': '7', 'EntryType': '2', 'Source': 'Src', 'Message': 'Msg', 'TimeGenerated': '2025-12-23T12:01:00'};
    final e = LogEntry.fromJson(json);
    expect(e.entryType, LogEntryType.warning);
    expect(e.index, 7);
  });

  test('handles missing or invalid TimeGenerated gracefully', () {
    final json = {'Index': 1, 'EntryType': 'Error', 'Source': 'S', 'Message': 'M', 'TimeGenerated': 'not-a-date'};
    final e = LogEntry.fromJson(json);
    expect(e.timeGenerated, isA<DateTime>());
  });

  test('toJson produces expected keys and formats', () {
    final now = DateTime.parse('2025-12-23T13:00:00');
    final entry = LogEntry(index: 3, entryType: LogEntryType.warning, source: 'X', message: 'Y', timeGenerated: now);
    final json = entry.toJson();
    expect(json['Index'], 3);
    expect(json['EntryType'], 'Warning');
    expect(json['TimeGenerated'], now.toIso8601String());
  });
}
