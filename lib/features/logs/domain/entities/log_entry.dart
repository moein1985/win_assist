import 'package:equatable/equatable.dart';

enum LogEntryType { error, warning }

class LogEntry extends Equatable {
  final int index;
  final LogEntryType entryType;
  final String source;
  final String message;
  final DateTime timeGenerated;

  const LogEntry({
    required this.index,
    required this.entryType,
    required this.source,
    required this.message,
    required this.timeGenerated,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    // EntryType may be numeric (1=Error,2=Warning) or string
    final dynamic rawType = json['EntryType'] ?? json['EntryType']?.toString();
    LogEntryType type = LogEntryType.error;

    if (rawType is num) {
      if (rawType == 2) {
        type = LogEntryType.warning;
      } else {
        type = LogEntryType.error;
      }
    } else if (rawType is String) {
      final v = rawType.toLowerCase();
      if (v.contains('warn')) {
        type = LogEntryType.warning;
      } else if (v.contains('error')) {
        type = LogEntryType.error;
      } else {
        // try parse numeric string
        final parsed = int.tryParse(v);
        if (parsed != null) {
          type = parsed == 2 ? LogEntryType.warning : LogEntryType.error;
        }
      }
    }

    final timeStr = json['TimeGenerated']?.toString() ?? '';
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(timeStr);
    } catch (_) {
      // Fallback: try to parse via DateTime.tryParse or use epoch
      parsedTime = DateTime.tryParse(timeStr) ?? DateTime.now();
    }

    return LogEntry(
      index: (json['Index'] is int) ? json['Index'] as int : int.tryParse(json['Index']?.toString() ?? '') ?? 0,
      entryType: type,
      source: json['Source']?.toString() ?? 'Unknown',
      message: json['Message']?.toString() ?? '',
      timeGenerated: parsedTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'Index': index,
        'EntryType': entryType == LogEntryType.error ? 'Error' : 'Warning',
        'Source': source,
        'Message': message,
        'TimeGenerated': timeGenerated.toIso8601String(),
      };

  @override
  List<Object?> get props => [index, entryType, source, message, timeGenerated];
}
