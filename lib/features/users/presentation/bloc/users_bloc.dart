import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/users/domain/usecases/get_local_users.dart';
import 'package:win_assist/features/users/domain/usecases/toggle_user_status.dart';
import 'package:win_assist/features/users/domain/usecases/reset_user_password.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class GetUsersEvent extends UsersEvent {}

class ToggleUserStatusEvent extends UsersEvent {
  final String username;
  final bool enable;

  const ToggleUserStatusEvent({required this.username, required this.enable});

  @override
  List<Object?> get props => [username, enable];
}

class ResetUserPasswordEvent extends UsersEvent {
  final String username;
  final String newPassword;

  const ResetUserPasswordEvent({required this.username, required this.newPassword});

  @override
  List<Object?> get props => [username, newPassword];
}

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<WindowsUser> users;

  const UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UsersActionInProgress extends UsersState {
  final String username;

  const UsersActionInProgress({required this.username});

  @override
  List<Object?> get props => [username];
}

class UsersActionSuccess extends UsersState {
  final String message;

  const UsersActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersError extends UsersState {
  final String message;

  const UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetLocalUsers getLocalUsers;
  final ToggleUserStatus toggleUserStatus;
  final ResetUserPassword resetUserPassword;
  final Logger logger;

  UsersBloc({
    required this.getLocalUsers,
    required this.toggleUserStatus,
    required this.resetUserPassword,
    required Logger? logger,
  })  : logger = logger ?? Logger(),
        super(UsersInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
    on<ResetUserPasswordEvent>(_onResetUserPassword);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Fetching local users');
    emit(UsersLoading());
    final result = await getLocalUsers(NoParams());
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error fetching users: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (users) {
        logger.i('UsersBloc: Users loaded: ${users.length}');
        emit(UsersLoaded(users: users));
      },
    );
  }

  Future<void> _onToggleUserStatus(ToggleUserStatusEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Toggling user ${event.username} -> ${event.enable}');
    emit(UsersActionInProgress(username: event.username));
    final result = await toggleUserStatus(ToggleUserStatusParams(username: event.username, enable: event.enable));
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error toggling user: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (_) {
        logger.i('UsersBloc: Toggled user successfully');
        emit(UsersActionSuccess(message: 'User ${event.username} ${event.enable ? 'enabled' : 'disabled'} successfully'));
        add(GetUsersEvent());
      },
    );
  }

  Future<void> _onResetUserPassword(ResetUserPasswordEvent event, Emitter<UsersState> emit) async {
    logger.d('UsersBloc: Resetting password for ${event.username}');
    emit(UsersActionInProgress(username: event.username));
    final result = await resetUserPassword(ResetUserPasswordParams(username: event.username, newPassword: event.newPassword));
    result.fold(
      (failure) {
        logger.e('UsersBloc: Error resetting password: ${failure.message}');
        emit(UsersError(message: failure.message));
      },
      (_) {
        logger.i('UsersBloc: Password reset successfully');
        emit(UsersActionSuccess(message: 'Password reset for ${event.username}'));
        add(GetUsersEvent());
      },
    );
  }
}
