import 'package:flutter_test/flutter_test.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';

void main() {
  test('ScheduledTask.fromJson handles numeric LastRunTime and numeric TaskName', () {
    final json = {
      'TaskName': 12345,
      'State': 'Ready',
      'LastRunTime': 1703465696000, // milliseconds epoch
      'LastTaskResult': '0',
    };

    final t = ScheduledTask.fromJson(json);
    expect(t.name, '12345');
    expect(t.state, 'Ready');
    expect(t.lastRunTime, DateTime.fromMillisecondsSinceEpoch(1703465696000));
    expect(t.lastTaskResult, 0);
  });
}
