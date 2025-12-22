import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/core/usecases/usecase.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/usecases/get_services.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

class GetServicesEvent extends ServicesEvent {}

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

class ServicesError extends ServicesState {
  final String message;

  const ServicesError({required this.message});

  @override
  List<Object> get props => [message];
}

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices getServices;
  final Logger logger;

  ServicesBloc({required this.getServices, required Logger? logger})
      : logger = logger ?? Logger(),
        super(ServicesInitial()) {
    on<GetServicesEvent>(_onGetServices);
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
}