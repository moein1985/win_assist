import 'package:flutter_test/flutter_test.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';

void main() {
  test('parses Running (various cases) correctly and preserves rawStatus', () {
    final json1 = {'ServiceName': 'svc1', 'DisplayName': 'Svc 1', 'Status': 'Running'};
    final s1 = ServiceItem.fromJson(json1);
    expect(s1.status, ServiceStatus.running);
    expect(s1.rawStatus, 'Running');

    final json2 = {'ServiceName': 'svc2', 'DisplayName': 'Svc 2', 'Status': 'running '};
    final s2 = ServiceItem.fromJson(json2);
    expect(s2.status, ServiceStatus.running);
    expect(s2.rawStatus, 'running ');

    final json3 = {'ServiceName': 'svc3', 'DisplayName': 'Svc 3', 'Status': '4'}; // numeric code for Running
    final s3 = ServiceItem.fromJson(json3);
    expect(s3.status, ServiceStatus.running);
  });

  test('parses numeric 1 as Stopped', () {
    final json = {'ServiceName': 'svc_stop', 'DisplayName': 'Svc Stop', 'Status': '1'};
    final s = ServiceItem.fromJson(json);
    expect(s.status, ServiceStatus.stopped);
  });
  test('parses Stopped (various cases) correctly', () {
    final json1 = {'ServiceName': 'svc1', 'DisplayName': 'Svc 1', 'Status': 'Stopped'};
    final s1 = ServiceItem.fromJson(json1);
    expect(s1.status, ServiceStatus.stopped);

    final json2 = {'ServiceName': 'svc2', 'DisplayName': 'Svc 2', 'Status': 'stopped'};
    final s2 = ServiceItem.fromJson(json2);
    expect(s2.status, ServiceStatus.stopped);

    final json3 = {'ServiceName': 'svc3', 'DisplayName': 'Svc 3', 'Status': '0'};
    final s3 = ServiceItem.fromJson(json3);
    expect(s3.status, ServiceStatus.stopped);
  });

  test('unknown or localized statuses become unknown', () {
    final json = {'ServiceName': 'x', 'DisplayName': 'x', 'Status': 'در حال اجرا'}; // Persian localized
    final s = ServiceItem.fromJson(json);
    expect(s.status, ServiceStatus.unknown);
    expect(s.rawStatus, 'در حال اجرا');
  });
}
