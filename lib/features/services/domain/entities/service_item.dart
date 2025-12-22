enum ServiceStatus { running, stopped, unknown }

class ServiceItem {
  final String name;
  final String displayName;
  final ServiceStatus status;

  ServiceItem({
    required this.name,
    required this.displayName,
    required this.status,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    ServiceStatus currentStatus;
    switch (json['Status']) {
      case 'Running':
        currentStatus = ServiceStatus.running;
        break;
      case 'Stopped':
        currentStatus = ServiceStatus.stopped;
        break;
      default:
        currentStatus = ServiceStatus.unknown;
    }

    return ServiceItem(
      name: json['ServiceName'] ?? 'N/A',
      displayName: json['DisplayName'] ?? 'N/A',
      status: currentStatus,
    );
  }
}