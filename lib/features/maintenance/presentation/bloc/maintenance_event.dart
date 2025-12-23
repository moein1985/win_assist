part of 'maintenance_bloc.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();

  @override
  List<Object?> get props => [];
}

class CleanTempEvent extends MaintenanceEvent {
  const CleanTempEvent();
}

class FlushDnsEvent extends MaintenanceEvent {
  const FlushDnsEvent();
}

class RestartServerEvent extends MaintenanceEvent {
  const RestartServerEvent();
}

class ShutdownServerEvent extends MaintenanceEvent {
  const ShutdownServerEvent();
}
