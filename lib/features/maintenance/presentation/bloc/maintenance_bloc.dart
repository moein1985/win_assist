import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/maintenance/domain/usecases/clean_temp_files.dart';
import 'package:win_assist/features/maintenance/domain/usecases/flush_dns.dart';
import 'package:win_assist/features/maintenance/domain/usecases/restart_server.dart';
import 'package:win_assist/features/maintenance/domain/usecases/shutdown_server.dart';

part 'maintenance_event.dart';
part 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final CleanTempFiles cleanTempFiles;
  final FlushDns flushDns;
  final RestartServer restartServer;
  final ShutdownServer shutdownServer;
  final Logger logger;

  MaintenanceBloc({
    required this.cleanTempFiles,
    required this.flushDns,
    required this.restartServer,
    required this.shutdownServer,
    required Logger? logger,
  })  : logger = logger ?? Logger(),
        super(MaintenanceInitial()) {
    on<CleanTempEvent>(_onCleanTemp);
    on<FlushDnsEvent>(_onFlushDns);
    on<RestartServerEvent>(_onRestart);
    on<ShutdownServerEvent>(_onShutdown);
  }

  Future<void> _onCleanTemp(CleanTempEvent event, Emitter<MaintenanceState> emit) async {
    logger.d('Maintenance: CleanTempFiles');
    emit(MaintenanceLoading(action: 'clean'));
    final result = await cleanTempFiles(NoParams());
    result.fold(
      (failure) {
        logger.e('CleanTempFiles failed: ${failure.message}');
        emit(MaintenanceError(message: failure.message));
      },
      (message) {
        logger.i('CleanTempFiles success: $message');
        emit(MaintenanceSuccess(message: message));
      },
    );
  }

  Future<void> _onFlushDns(FlushDnsEvent event, Emitter<MaintenanceState> emit) async {
    logger.d('Maintenance: FlushDns');
    emit(MaintenanceLoading(action: 'flush'));
    final result = await flushDns(NoParams());
    result.fold(
      (failure) {
        logger.e('FlushDns failed: ${failure.message}');
        emit(MaintenanceError(message: failure.message));
      },
      (message) {
        logger.i('FlushDns success: $message');
        emit(MaintenanceSuccess(message: message));
      },
    );
  }

  Future<void> _onRestart(RestartServerEvent event, Emitter<MaintenanceState> emit) async {
    logger.d('Maintenance: RestartServer');
    emit(MaintenanceLoading(action: 'restart'));
    final result = await restartServer(NoParams());
    result.fold(
      (failure) {
        logger.e('Restart failed: ${failure.message}');
        emit(MaintenanceError(message: failure.message));
      },
      (_) {
        logger.i('Restart command issued');
        emit(MaintenanceSuccess(message: 'Restart command issued'));
      },
    );
  }

  Future<void> _onShutdown(ShutdownServerEvent event, Emitter<MaintenanceState> emit) async {
    logger.d('Maintenance: ShutdownServer');
    emit(MaintenanceLoading(action: 'shutdown'));
    final result = await shutdownServer(NoParams());
    result.fold(
      (failure) {
        logger.e('Shutdown failed: ${failure.message}');
        emit(MaintenanceError(message: failure.message));
      },
      (_) {
        logger.i('Shutdown command issued');
        emit(MaintenanceSuccess(message: 'Shutdown command issued'));
      },
    );
  }
}
