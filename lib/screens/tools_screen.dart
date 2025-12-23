import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/users/presentation/pages/users_page.dart';
import 'package:win_assist/injection_container.dart' as di;
import 'package:win_assist/features/users/presentation/bloc/users_bloc.dart';
// Maintenance
import 'package:win_assist/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:win_assist/features/maintenance/presentation/pages/maintenance_page.dart';
// Logs
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_event.dart';
import 'package:win_assist/features/logs/presentation/pages/logs_page.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Local Users Manager'),
              subtitle: const Text('Manage local users on the server'),
              trailing: const Icon(Icons.people),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<UsersBloc>(
                  create: (_) => di.sl<UsersBloc>()..add(GetUsersEvent()),
                  child: const UsersPage(),
                )));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('System Maintenance'),
              subtitle: const Text('Cleanup and power operations'),
              trailing: const Icon(Icons.build),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<MaintenanceBloc>(
                  create: (_) => di.sl<MaintenanceBloc>(),
                  child: const MaintenancePage(),
                )));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('System Event Logs'),
              subtitle: const Text('View recent system errors and warnings'),
              trailing: const Icon(Icons.history),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<LogsBloc>(
                  create: (_) => di.sl<LogsBloc>()..add(GetLogsEvent()),
                  child: const LogsPage(),
                )));
              },
            ),
          ),
        ],
      ),
    );
  }
}
