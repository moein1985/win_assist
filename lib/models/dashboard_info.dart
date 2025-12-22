import 'dart:math';

class DashboardInfo {
  final String osName;
  final String model;
  final double totalRamInGB;
  final double freeRamInGB;
  final double ramUsagePercentage;
  final double totalStorageInGB;
  final double freeStorageInGB;
  final double storageUsagePercentage;

  DashboardInfo({
    required this.osName,
    required this.model,
    required this.totalRamInGB,
    required this.freeRamInGB,
    required this.ramUsagePercentage,
    required this.totalStorageInGB,
    required this.freeStorageInGB,
    required this.storageUsagePercentage,
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    final totalRamBytes = (json['CsTotalPhysicalMemory'] as num?)?.toDouble() ?? 0.0;
    final freeRamBytes = (json['OsFreePhysicalMemoryInBytes'] as num?)?.toDouble() ?? 0.0;

    // Drive info is in Bytes
    final totalStorageBytes = (json['DriveC_Total'] as num?)?.toDouble() ?? 0.0;
    final freeStorageBytes = (json['DriveC_Free'] as num?)?.toDouble() ?? 0.0;

    // Conversion factor
    const bytesInGB = 1024 * 1024 * 1024;

    final totalRamGB = totalRamBytes / bytesInGB;
    final freeRamGB = freeRamBytes / bytesInGB;
    final usedRamGB = max(0, totalRamGB - freeRamGB);

    final totalStorageGB = totalStorageBytes / bytesInGB;
    final freeStorageGB = freeStorageBytes / bytesInGB;
    final usedStorageGB = max(0, totalStorageGB - freeStorageGB);

    return DashboardInfo(
      osName: json['OsName'] ?? 'N/A',
      model: json['CsModel'] ?? 'N/A',
      totalRamInGB: totalRamGB,
      freeRamInGB: freeRamGB,
      ramUsagePercentage: totalRamGB > 0 ? (usedRamGB / totalRamGB) : 0,
      totalStorageInGB: totalStorageGB,
      freeStorageInGB: freeStorageGB,
      storageUsagePercentage: totalStorageGB > 0 ? (usedStorageGB / totalStorageGB) : 0,
    );
  }

  // Helper for creating a loading/initial state
  factory DashboardInfo.initial() {
    return DashboardInfo(
      osName: 'Loading...',
      model: 'N/A',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
    );
  }
}