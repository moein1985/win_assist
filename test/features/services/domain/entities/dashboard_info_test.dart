import 'package:flutter_test/flutter_test.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

void main() {
  test('isDomainController getter works for role 4 and 5', () {
    final d1 = DashboardInfo(
      osName: 'x',
      model: 'm',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
      domainRole: 4,
    );
    expect(d1.isDomainController, isTrue);

    final d2 = DashboardInfo(
      osName: 'x',
      model: 'm',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
      domainRole: 5,
    );
    expect(d2.isDomainController, isTrue);

    final d3 = DashboardInfo(
      osName: 'x',
      model: 'm',
      totalRamInGB: 0,
      freeRamInGB: 0,
      ramUsagePercentage: 0,
      totalStorageInGB: 0,
      freeStorageInGB: 0,
      storageUsagePercentage: 0,
      domainRole: 2,
    );
    expect(d3.isDomainController, isFalse);
  });
}
