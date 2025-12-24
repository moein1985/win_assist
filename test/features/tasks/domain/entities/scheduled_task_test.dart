import 'package:flutter_test/flutter_test.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';

void main() {
  test('ScheduledTask fromJson parses fields', () {
    final json = {
      'TaskName': 'MyTask',
      'State': 'Ready',
      'LastRunTime': '2025-12-24T12:34:56',
      'LastTaskResult': 0,
    };

    final t = ScheduledTask.fromJson(json);
    expect(t.name, 'MyTask');
    expect(t.state, 'Ready');
    expect(t.lastRunTime, DateTime.parse('2025-12-24T12:34:56'));
    expect(t.lastTaskResult, 0);
  });
}
