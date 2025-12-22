import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/usecases/get_dashboard_info.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class GetDashboardInfoEvent extends DashboardEvent {}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardInfo dashboardInfo;

  const DashboardLoaded({required this.dashboardInfo});

  @override
  List<Object> get props => [dashboardInfo];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardInfo getDashboardInfo;
  final Logger logger;

  DashboardBloc({required this.getDashboardInfo, required Logger? logger})
      : logger = logger ?? Logger(),
        super(DashboardInitial()) {
    on<GetDashboardInfoEvent>(_onGetDashboardInfo);
  }

  Future<void> _onGetDashboardInfo(
    GetDashboardInfoEvent event,
    Emitter<DashboardState> emit,
  ) async {
    logger.d('DashboardBloc: Fetching dashboard info');
    emit(DashboardLoading());
    final result = await getDashboardInfo(NoParams());
    result.fold(
      (failure) {
        logger.e('DashboardBloc: Error fetching dashboard info: ${failure.message}');
        emit(DashboardError(message: failure.message));
      },
      (dashboardInfo) {
        logger.i('DashboardBloc: Dashboard info loaded successfully');
        emit(DashboardLoaded(dashboardInfo: dashboardInfo));
      },
    );
  }
}