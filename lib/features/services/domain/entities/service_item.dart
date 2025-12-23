enum ServiceStatus { running, stopped, unknown }

class ServiceItem {
  final String name;
  final String displayName;
  final ServiceStatus status;
  final String rawStatus;

  ServiceItem({
    required this.name,
    required this.displayName,
    required this.status,
    this.rawStatus = '',
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    // Preserve original raw status for debugging
    final raw = json['Status']?.toString() ?? '';
    final normalized = raw.trim().toLowerCase();

    ServiceStatus currentStatus;

    if (normalized.isEmpty) {
      currentStatus = ServiceStatus.unknown;
    } else if (normalized.contains('run') || normalized == 'running') {
      currentStatus = ServiceStatus.running;
    } else if (normalized.contains('stop') || normalized == 'stopped' || normalized.contains('pause') || normalized == 'paused') {
      currentStatus = ServiceStatus.stopped;
    } else if (int.tryParse(normalized) != null) {
      // Numeric ServiceControllerStatus codes from Windows: 1=Stopped,2=StartPending,3=StopPending,4=Running,5=ContinuePending,6=PausePending,7=Paused
      final n = int.parse(normalized);
      if (n == 4) {
        currentStatus = ServiceStatus.running;
      } else if (n == 1 || n == 7 || n == 0) {
        // 1=Stopped, 7=Paused, 0=some systems may use 0 for stopped
        currentStatus = ServiceStatus.stopped;
      } else {
        currentStatus = ServiceStatus.unknown;
      }
    } else {
      // Unknown or localized string
      currentStatus = ServiceStatus.unknown;
    }

    return ServiceItem(
      name: json['ServiceName'] ?? 'N/A',
      displayName: json['DisplayName'] ?? 'N/A',
      status: currentStatus,
      rawStatus: raw,
    );
  }
}