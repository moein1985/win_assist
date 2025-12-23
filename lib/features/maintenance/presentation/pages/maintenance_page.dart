import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/maintenance/presentation/bloc/maintenance_bloc.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  late MaintenanceBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<MaintenanceBloc>(context);
  }

  Future<bool?> _confirmDanger(BuildContext context, String actionLabel) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure? This will disconnect all users. ($actionLabel)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Maintenance')),
      body: BlocListener<MaintenanceBloc, MaintenanceState>(
        listener: (context, state) {
          if (state is MaintenanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MaintenanceError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Optimization', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cleaning_services),
                        label: const Text('Clean Temp Files'),
                        onPressed: () => _bloc.add(CleanTempEvent()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.network_check),
                        label: const Text('Flush DNS'),
                        onPressed: () => _bloc.add(FlushDnsEvent()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text('Critical Zone', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Use with caution', style: TextStyle(color: Colors.orange)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Restart Server'),
                            onPressed: () async {
                              final confirmed = await _confirmDanger(context, 'Restart');
                              if (confirmed == true) {
                                _bloc.add(RestartServerEvent());
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.power_settings_new),
                            label: const Text('Shutdown Server'),
                            onPressed: () async {
                              final confirmed = await _confirmDanger(context, 'Shutdown');
                              if (confirmed == true) {
                                _bloc.add(ShutdownServerEvent());
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              BlocBuilder<MaintenanceBloc, MaintenanceState>(
                builder: (context, state) {
                  if (state is MaintenanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
