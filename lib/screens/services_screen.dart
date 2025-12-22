import 'package:flutter/material.dart';
import 'package:win_assist/models/service_item.dart';
import 'package:win_assist/services/windows_service.dart';

class ServicesScreen extends StatefulWidget {
  final WindowsService service;

  const ServicesScreen({super.key, required this.service});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Future<List<ServiceItem>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _fetchServices();
  }

  Future<List<ServiceItem>> _fetchServices() {
    return widget.service.getServices();
  }

  Future<void> _refresh() async {
    setState(() {
      _servicesFuture = _fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceItem>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error fetching services: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return const Center(child: Text('No services found.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final statusColor = service.status == ServiceStatus.running ? Colors.green : Colors.red;
              final statusText = service.status.toString().split('.').last;

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
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}