part of 'maintenance_bloc.dart';

abstract class MaintenanceState extends Equatable {
  const MaintenanceState();

  @override
  List<Object?> get props => [];
}

class MaintenanceInitial extends MaintenanceState {
  const MaintenanceInitial();
}

class MaintenanceLoading extends MaintenanceState {
  final String action;
  const MaintenanceLoading({required this.action});

  @override
  List<Object?> get props => [action];
}

class MaintenanceSuccess extends MaintenanceState {
  final String message;
  const MaintenanceSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class MaintenanceError extends MaintenanceState {
  final String message;
  const MaintenanceError({required this.message});

  @override
  List<Object?> get props => [message];
}
