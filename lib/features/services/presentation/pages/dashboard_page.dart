import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/presentation/widgets/ram_card.dart';
import 'package:win_assist/features/services/presentation/widgets/storage_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardError) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardBloc>().add(GetDashboardInfoEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is DashboardLoaded) {
          final info = state.dashboardInfo;
          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardBloc>().add(GetDashboardInfoEvent()),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('OS: ${info.osName}'),
                Text('Model: ${info.model}'),
                const SizedBox(height: 24),
                RamCard(info: info),
                const SizedBox(height: 16),
                StorageCard(info: info),
              ],
            ),
          );
        }
        return const Center(child: Text('Welcome to Dashboard'));
      },
    );
  }
}