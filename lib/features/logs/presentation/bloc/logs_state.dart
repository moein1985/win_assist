import 'package:equatable/equatable.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';

abstract class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object?> get props => [];
}

class LogsInitial extends LogsState {}
class LogsLoading extends LogsState {}

class LogsLoaded extends LogsState {
  final List<LogEntry> logs;

  const LogsLoaded({required this.logs});

  @override
  List<Object?> get props => [logs];
}

class LogsError extends LogsState {
  final String message;

  const LogsError({required this.message});

  @override
  List<Object?> get props => [message];
}
