import 'package:flutter/material.dart';
import 'package:win_assist/models/dashboard_info.dart';
import 'package:win_assist/services/windows_service.dart';
import 'package:win_assist/widgets/ram_card.dart';
import 'package:win_assist/widgets/storage_card.dart';

class DashboardScreen extends StatefulWidget {
  final WindowsService service;

  const DashboardScreen({super.key, required this.service});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardInfo> _dashboardInfoFuture;

  @override
  void initState() {
    super.initState();
    _dashboardInfoFuture = _fetchDashboardInfo();
  }

  Future<DashboardInfo> _fetchDashboardInfo() {
    return widget.service.getDashboardInfo();
  }

  void _refresh() {
    setState(() {
      _dashboardInfoFuture = _fetchDashboardInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardInfo>(
      future: _dashboardInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error fetching data: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final info = snapshot.data ?? DashboardInfo.initial();

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
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
      },
    );
  }
}