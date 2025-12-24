import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/injection_container.dart' as di;
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Running', 'Stopped'
  late final Logger logger;

  @override
  void initState() {
    super.initState();
    // Use DI-provided logger when available
    try {
      logger = di.sl<Logger>();
    } catch (_) {
      logger = Logger();
    }
  }

  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v.trim());
    logger.d('ServicesPage: search changed -> "$_searchQuery"');
  }

  void _onFilterChanged(String status, bool selected) {
    // Toggle: deselecting chip will return to 'All'
    final newStatus = selected ? status : 'All';
    setState(() => _filterStatus = newStatus);
    logger.d('ServicesPage: filter changed -> "$_filterStatus" (selected: $selected)');
  }

  void _onDebugPressed(List<ServiceItem> allServices) async {
    final total = allServices.length;
    final runningCount = allServices.where((s) => s.status == ServiceStatus.running).length;
    final stoppedCount = allServices.where((s) => s.status == ServiceStatus.stopped).length;
    final unknownCount = total - runningCount - stoppedCount;

    final sampleList = allServices.take(20).map((s) => '${s.name} => rawStatus="${s.rawStatus}" status="${s.status}"').toList();
    final sample = sampleList.join('\n');

    final body = 'Services debug report\nTotal: $total\nRunning: $runningCount\nStopped: $stoppedCount\nUnknown: $unknownCount\n\nSample:\n$sample';

    logger.i('ServicesPage Debug:\n$body');

    await Clipboard.setData(ClipboardData(text: body));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debug report copied to clipboard')));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Services Debug Report'),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          TextButton(onPressed: () { Clipboard.setData(ClipboardData(text: body)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }, child: const Text('Copy')),
        ],
      ),
    );
  }

  List<ServiceItem> _applyFiltersAndSort(List<ServiceItem> services) {
    final q = _searchQuery.toLowerCase();

    // Filter by search
    var filtered = services.where((s) {
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) || s.displayName.toLowerCase().contains(q);
    }).toList();

    // Filter by status
    if (_filterStatus == 'Running') {
      filtered = filtered.where((s) => s.status == ServiceStatus.running).toList();
    } else if (_filterStatus == 'Stopped') {
      filtered = filtered.where((s) => s.status == ServiceStatus.stopped).toList();
    }

    // Smart sort: running first, then unknown, then stopped. Within groups, sort by displayName.
    filtered.sort((a, b) {
      int score(ServiceStatus s) {
        switch (s) {
          case ServiceStatus.running:
            return 0;
          case ServiceStatus.unknown:
            return 1;
          case ServiceStatus.stopped:
            return 2;
        }
      }

      final sa = score(a.status);
      final sb = score(b.status);
      if (sa != sb) return sa.compareTo(sb);
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered;
  }

  Widget _buildFilterChips() {
    const options = ['All', 'Running', 'Stopped'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((o) {
          final selected = _filterStatus == o;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              key: Key('filter_chip_$o'),
              label: Text(o),
              selected: selected,
              onSelected: (selected) => _onFilterChanged(o, selected),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        key: const Key('services_search_field'),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search by Name or Display Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          isDense: true,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service, bool isUpdating) {
    Color iconColor;
    IconData iconData;
    switch (service.status) {
      case ServiceStatus.running:
        iconColor = Colors.green;
        iconData = Icons.play_circle;
        break;
      case ServiceStatus.stopped:
        iconColor = Colors.red;
        iconData = Icons.stop_circle;
        break;
      default:
        iconColor = Colors.orange;
        iconData = Icons.help_outline;
    }

    return Card(
      key: Key('service_card_${service.name}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(service.name, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // small popup menu
            PopupMenuButton<ServiceAction>(
              onSelected: (action) {
                logger.i('Service Action: ${action.toString().split('.').last} on ${service.name}');
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
  }

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
          } else if (state is ServicesError && state is! ServicesActionSuccess) {
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
            final services = _applyFiltersAndSort(state.services);
            logger.d('ServicesPage: applied filters "$_filterStatus" search="$_searchQuery" -> ${services.length}/${state.services.length}');
            if (services.isEmpty) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        IconButton(key: const Key('debug_button'), tooltip: 'Export Debug', icon: const Icon(Icons.bug_report), onPressed: () => _onDebugPressed(state.services)),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildFilterChips()),
                  const Expanded(child: Center(child: Text('No services found.'))),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async => context.read<ServicesBloc>().add(GetServicesEvent()),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        IconButton(key: const Key('debug_button'), tooltip: 'Export Debug', icon: const Icon(Icons.bug_report), onPressed: () => _onDebugPressed(state.services)),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildFilterChips()),
                  Expanded(
                    child: ListView.builder(
                      key: const Key('services_list_view'),
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isUpdating = state is ServicesActionInProgress && (state as ServicesActionInProgress).serviceName == service.name;
                        return _buildServiceCard(context, service, isUpdating);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              _buildSearchBar(),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildFilterChips()),
              const Expanded(child: Center(child: Text('Welcome to Services'))),
            ],
          );
        },
      ),
    );
  }
} 