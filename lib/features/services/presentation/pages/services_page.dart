import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state is ServicesActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ServicesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServicesError && !(state is ServicesActionSuccess)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ServicesBloc>().add(GetServicesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ServicesLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return const Center(child: Text('No services found.'));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<ServicesBloc>().add(GetServicesEvent()),
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final statusColor = service.status == ServiceStatus.running ? Colors.green : Colors.red;
                  final statusText = service.status.toString().split('.').last;

                  final isUpdating = state is ServicesActionInProgress && (state as ServicesActionInProgress).serviceName == service.name;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(service.displayName),
                      subtitle: Text(service.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: statusColor, size: 12),
                          const SizedBox(width: 8),
                          Text(statusText),
                          PopupMenuButton<ServiceAction>(
                            onSelected: (action) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Performing ${action.toString().split('.').last} on ${service.displayName}...')));
                              context.read<ServicesBloc>().add(UpdateServiceEvent(serviceName: service.name, action: action));
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.start,
                                enabled: service.status != ServiceStatus.running && !isUpdating,
                                child: const Text('Start'),
                              ),
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.stop,
                                enabled: service.status != ServiceStatus.stopped && !isUpdating,
                                child: const Text('Stop'),
                              ),
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.restart,
                                enabled: !isUpdating,
                                child: const Text('Restart'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Welcome to Services'));
        },
      ),
    );
  }
} 