class ScheduledTask {
  final String name;
  final String state;
  final DateTime? lastRunTime;
  final int? lastTaskResult;

  ScheduledTask({
    required this.name,
    required this.state,
    this.lastRunTime,
    this.lastTaskResult,
  });

  factory ScheduledTask.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTime;
    final dynamic lastRunRaw = json['LastRunTime'];
    if (lastRunRaw != null) {
      try {
        if (lastRunRaw is String && lastRunRaw.trim().isNotEmpty) {
          parsedTime = DateTime.tryParse(lastRunRaw);
        } else if (lastRunRaw is num) {
          // Interpret numeric as milliseconds since epoch
          parsedTime = DateTime.fromMillisecondsSinceEpoch(lastRunRaw.toInt());
        } else {
          parsedTime = null;
        }
      } catch (_) {
        parsedTime = null;
      }
    }

    final lastResult = (json['LastTaskResult'] is num)
        ? (json['LastTaskResult'] as num).toInt()
        : int.tryParse(json['LastTaskResult']?.toString() ?? '');

    return ScheduledTask(
      name: (json['TaskName']?.toString() ?? json['Task']?.toString() ?? 'Unknown'),
      state: (json['State']?.toString() ?? 'Unknown'),
      lastRunTime: parsedTime,
      lastTaskResult: lastResult,
    );
  }
}
