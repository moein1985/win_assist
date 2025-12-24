enum TaskState { running, ready, queued, disabled, unknown }

class ScheduledTask {
  final String name;
  final TaskState state;
  final DateTime? lastRunTime;
  final int? lastTaskResult;

  ScheduledTask({
    required this.name,
    required this.state,
    this.lastRunTime,
    this.lastTaskResult,
  });

  String get stateLabel {
    switch (state) {
      case TaskState.running:
        return 'Running';
      case TaskState.ready:
        return 'Ready';
      case TaskState.queued:
        return 'Queued';
      case TaskState.disabled:
        return 'Disabled';
      case TaskState.unknown:
      default:
        return 'Unknown';
    }
  }

  String get resultLabel {
    final r = lastTaskResult;
    if (r == null) return 'N/A';
    return r == 0 ? 'Success' : 'Error ($r)';
  }

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

    // Map various possible representations of state (numeric or textual) to TaskState
    TaskState mapState(dynamic s) {
      if (s == null) return TaskState.unknown;
      if (s is num) {
        switch (s.toInt()) {
          case 4:
            return TaskState.running;
          case 3:
            return TaskState.ready;
          case 2:
            return TaskState.queued;
          case 1:
            return TaskState.disabled;
          default:
            return TaskState.unknown;
        }
      }
      final st = s.toString().toLowerCase();
      if (st.contains('running')) return TaskState.running;
      if (st.contains('ready')) return TaskState.ready;
      if (st.contains('queued')) return TaskState.queued;
      if (st.contains('disabled')) return TaskState.disabled;
      return TaskState.unknown;
    }

    return ScheduledTask(
      name: (json['TaskName']?.toString() ?? json['Task']?.toString() ?? 'Unknown'),
      state: mapState(json['State']),
      lastRunTime: parsedTime,
      lastTaskResult: lastResult,
    );
  }
}
