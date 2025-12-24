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
// Dashboard (for domain detection)
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
// Tasks
import 'package:win_assist/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:win_assist/features/tasks/presentation/pages/tasks_page.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashState) {
              var title = 'Local Users Manager';
              var subtitle = 'Manage local users on the server';
              if (dashState is DashboardLoaded) {
                final isDc = dashState.dashboardInfo.isDomainController;
                if (isDc) {
                  title = 'User Manager (AD)';
                  subtitle = 'Manage Active Directory users on the domain controller';
                } else {
                  title = 'User Manager';
                  subtitle = 'Manage local users on the server';
                }
              }

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: const Icon(Icons.people),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<UsersBloc>(
                      create: (_) => di.sl<UsersBloc>()..add(GetUsersEvent()),
                      child: const UsersPage(),
                    )));
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Task Scheduler'),
              subtitle: const Text('View and manage scheduled tasks'),
              trailing: const Icon(Icons.schedule),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<TasksBloc>(
                  create: (_) => di.sl<TasksBloc>()..add(GetTasksEvent()),
                  child: const TasksPage(),
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
