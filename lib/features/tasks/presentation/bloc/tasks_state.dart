import 'package:equatable/equatable.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<ScheduledTask> tasks;

  const TasksLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

class TasksActionInProgress extends TasksState {}
