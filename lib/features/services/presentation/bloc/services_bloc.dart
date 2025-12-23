import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/usecases/get_services.dart';
import 'package:win_assist/features/services/domain/usecases/update_service_status.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

class GetServicesEvent extends ServicesEvent {}

class UpdateServiceEvent extends ServicesEvent {
  final String serviceName;
  final ServiceAction action;

  const UpdateServiceEvent({required this.serviceName, required this.action});

  @override
  List<Object> get props => [serviceName, action];
}

abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceItem> services;

  const ServicesLoaded({required this.services});

  @override
  List<Object> get props => [services];
}

class ServicesActionInProgress extends ServicesState {
  final String serviceName;

  const ServicesActionInProgress({required this.serviceName});

  @override
  List<Object> get props => [serviceName];
}

class ServicesActionSuccess extends ServicesState {
  final String message;

  const ServicesActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ServicesError extends ServicesState {
  final String message;

  const ServicesError({required this.message});

  @override
  List<Object> get props => [message];
}

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices getServices;
  final UpdateServiceStatus updateServiceStatus;
  final Logger logger;

  ServicesBloc({required this.getServices, required this.updateServiceStatus, required Logger? logger})
      : logger = logger ?? Logger(),
        super(ServicesInitial()) {
    on<GetServicesEvent>(_onGetServices);
    on<UpdateServiceEvent>(_onUpdateService);
  }

  Future<void> _onGetServices(
    GetServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    logger.d('ServicesBloc: Fetching services');
    emit(ServicesLoading());
    final result = await getServices(NoParams());
    result.fold(
      (failure) {
        logger.e('ServicesBloc: Error fetching services: ${failure.message}');
        emit(ServicesError(message: failure.message));
      },
      (services) {
        logger.i('ServicesBloc: Services loaded successfully: ${services.length} services');
        emit(ServicesLoaded(services: services));
      },
    );
  }

  Future<void> _onUpdateService(
    UpdateServiceEvent event,
    Emitter<ServicesState> emit,
  ) async {
    logger.d('ServicesBloc: Updating service ${event.serviceName} action: ${event.action}');
    emit(ServicesActionInProgress(serviceName: event.serviceName));

    final result = await updateServiceStatus(UpdateServiceParams(serviceName: event.serviceName, action: event.action));
    result.fold(
      (failure) {
        logger.e('ServicesBloc: Error updating service: ${failure.message}');
        emit(ServicesError(message: failure.message));
      },
      (_) {
        logger.i('ServicesBloc: Service updated successfully');
        emit(ServicesActionSuccess(message: 'Service ${event.serviceName} ${event.action.toString().split('.').last} successfully'));
        add(GetServicesEvent());
      },
    );
  }
} 