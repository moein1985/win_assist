import 'package:equatable/equatable.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksEvent extends TasksEvent {}

class RunTaskEvent extends TasksEvent {
  final String taskName;

  const RunTaskEvent(this.taskName);

  @override
  List<Object?> get props => [taskName];
}

class StopTaskEvent extends TasksEvent {
  final String taskName;

  const StopTaskEvent(this.taskName);

  @override
  List<Object?> get props => [taskName];
}
