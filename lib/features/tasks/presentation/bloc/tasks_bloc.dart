import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/tasks/domain/usecases/get_tasks.dart';
import 'package:win_assist/features/tasks/domain/usecases/run_task.dart';
import 'package:win_assist/features/tasks/domain/usecases/stop_task.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasks;
  final RunTask runTask;
  final StopTask stopTask;
  final Logger logger;

  TasksBloc({required this.getTasks, required this.runTask, required this.stopTask, required Logger? logger})
      : logger = logger ?? Logger(),
        super(TasksInitial()) {
    on<GetTasksEvent>(_onGetTasks);
    on<RunTaskEvent>(_onRunTask);
    on<StopTaskEvent>(_onStopTask);
  }

  Future<void> _onGetTasks(GetTasksEvent event, Emitter<TasksState> emit) async {
    logger.d('TasksBloc: Fetching tasks');
    emit(TasksLoading());
    final result = await getTasks(NoParams());
    result.fold(
      (failure) {
        logger.e('TasksBloc: Error fetching tasks: ${failure.message}');
        emit(TasksError(failure.message));
      },
      (tasks) {
        emit(TasksLoaded(tasks: tasks));
      },
    );
  }

  Future<void> _onRunTask(RunTaskEvent event, Emitter<TasksState> emit) async {
    logger.d('TasksBloc: Running task ${event.taskName}');
    emit(TasksActionInProgress());

    final result = await runTask(event.taskName);

    // Handle failure synchronously so we don't leave async work running after the handler completes
    result.fold(
      (failure) {
        logger.e('TasksBloc: Error running task: ${failure.message}');
        emit(TasksError(failure.message));
      },
      (_) => null,
    );

    // If success, refresh list (awaited sequentially)
    if (result.isRight()) {
      final refreshed = await getTasks(NoParams());
      refreshed.fold(
        (f) {
          logger.e('TasksBloc: Error refreshing tasks after run: ${f.message}');
          emit(TasksError(f.message));
        },
        (tasks) => emit(TasksLoaded(tasks: tasks)),
      );
    }
  }

  Future<void> _onStopTask(StopTaskEvent event, Emitter<TasksState> emit) async {
    logger.d('TasksBloc: Stopping task ${event.taskName}');
    emit(TasksActionInProgress());

    final result = await stopTask(event.taskName);

    // Handle failure synchronously so we don't leave async work running after the handler completes
    result.fold(
      (failure) {
        logger.e('TasksBloc: Error stopping task: ${failure.message}');
        emit(TasksError(failure.message));
      },
      (_) => null,
    );

    // If success, refresh list (awaited sequentially)
    if (result.isRight()) {
      final refreshed = await getTasks(NoParams());
      refreshed.fold(
        (f) {
          logger.e('TasksBloc: Error refreshing tasks after stop: ${f.message}');
          emit(TasksError(f.message));
        },
        (tasks) => emit(TasksLoaded(tasks: tasks)),
      );
    }
  }
}
