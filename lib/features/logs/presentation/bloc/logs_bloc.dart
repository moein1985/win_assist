import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/logs/domain/usecases/get_system_logs.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';

class LogsBloc extends Bloc<LogsEvent, LogsState> {
  final GetSystemLogs getSystemLogs;
  final Logger logger;

  LogsBloc({required this.getSystemLogs, required Logger? logger})
      : logger = logger ?? Logger(),
        super(LogsInitial()) {
    on<GetLogsEvent>(_onGetLogs);
  }

  Future<void> _onGetLogs(GetLogsEvent event, Emitter<LogsState> emit) async {
    logger.d('LogsBloc: Fetching system logs');
    emit(LogsLoading());
    final result = await getSystemLogs(NoParams());
    result.fold((failure) {
      logger.e('LogsBloc: Error fetching logs: ${failure.message}');
      emit(LogsError(message: failure.message));
    }, (logs) {
      logger.i('LogsBloc: Loaded ${logs.length} logs');
      emit(LogsLoaded(logs: logs));
    });
  }
}
