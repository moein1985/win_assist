import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';
import 'package:win_assist/features/sessions/domain/usecases/get_remote_sessions.dart';
import 'package:win_assist/features/sessions/domain/usecases/kill_session.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class GetSessionsEvent extends SessionsEvent {}

class KillSessionEvent extends SessionsEvent {
  final int sessionId;
  final String username;

  const KillSessionEvent({required this.sessionId, required this.username});

  @override
  List<Object?> get props => [sessionId, username];
}

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState {
  final List<WindowsSession> sessions;

  const SessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class SessionsActionInProgress extends SessionsState {
  final int sessionId;

  const SessionsActionInProgress({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class SessionsActionSuccess extends SessionsState {
  final String message;

  const SessionsActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SessionsError extends SessionsState {
  final String message;

  const SessionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetRemoteSessions getRemoteSessions;
  final KillSession killSession;
  final Logger logger;

  SessionsBloc({required this.getRemoteSessions, required this.killSession, required Logger? logger})
      : logger = logger ?? Logger(),
        super(SessionsInitial()) {
    on<GetSessionsEvent>(_onGetSessions);
    on<KillSessionEvent>(_onKillSession);
  }

  Future<void> _onGetSessions(GetSessionsEvent event, Emitter<SessionsState> emit) async {
    logger.d('SessionsBloc: Fetching remote sessions');
    emit(SessionsLoading());
    final result = await getRemoteSessions(NoParams());
    result.fold(
      (failure) {
        logger.e('SessionsBloc: Error fetching sessions: ${failure.message}');
        emit(SessionsError(message: failure.message));
      },
      (sessions) {
        logger.i('SessionsBloc: Loaded ${sessions.length} sessions');
        emit(SessionsLoaded(sessions: sessions));
      },
    );
  }

  Future<void> _onKillSession(KillSessionEvent event, Emitter<SessionsState> emit) async {
    logger.d('SessionsBloc: Killing session ${event.sessionId}');
    emit(SessionsActionInProgress(sessionId: event.sessionId));
    final result = await killSession(KillSessionParams(sessionId: event.sessionId));
    result.fold(
      (failure) {
        logger.e('SessionsBloc: Error killing session: ${failure.message}');
        emit(SessionsError(message: failure.message));
      },
      (_) {
        logger.i('SessionsBloc: Session killed successfully');
        emit(SessionsActionSuccess(message: 'Session ${event.sessionId} for ${event.username} terminated'));
        add(GetSessionsEvent());
      },
    );
  }
}
