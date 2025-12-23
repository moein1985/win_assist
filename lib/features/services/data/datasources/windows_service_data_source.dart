import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';

abstract class WindowsServiceDataSource {
  Future<DashboardInfo> getDashboardInfo();
  Future<List<ServiceItem>> getServices();
  Future<void> connect(String ip, int port, String username, String password);
  void disconnect();
  bool get isConnected;

  // New: Update status of a service
  Future<void> updateServiceStatus(String serviceName, ServiceAction action);
}

class WindowsServiceDataSourceImpl implements WindowsServiceDataSource {
  final Logger logger;

  WindowsServiceDataSourceImpl({required this.logger});

  SSHClient? _client;

  @override
  bool get isConnected => _client != null && !_client!.isClosed;

  @override
  Future<void> connect(String ip, int port, String username, String password) async {
    if (isConnected) {
      logger.i('Already connected.');
      return;
    }
    logger.i('Connecting to $ip:$port...');
    try {
      final socket = await SSHSocket.connect(ip, port, timeout: const Duration(seconds: 15));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      // Wait for the client to be ready
      await _client!.authenticated;
      logger.i('SSH connection successful.');
    } catch (e) {
      logger.e('Connection failed: $e');
      _client = null;
      rethrow;
    }
  }

  @override
  Future<DashboardInfo> getDashboardInfo() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''$ProgressPreference = 'SilentlyContinue'; $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem; $csInfo = Get-CimInstance -ClassName Win32_ComputerSystem; $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"; @{ OsName = if ($osInfo.Caption) { $osInfo.Caption } else { "N/A" }; CsModel = if ($csInfo.Model) { $csInfo.Model } else { "N/A" }; CsTotalPhysicalMemory = if ($csInfo.TotalPhysicalMemory) { $csInfo.TotalPhysicalMemory } else { 0 }; OsFreePhysicalMemoryInBytes = if ($osInfo.FreePhysicalMemory) { [long]($osInfo.FreePhysicalMemory * 1024) } else { 0 }; DriveC_Free = if ($diskInfo.FreeSpace) { $diskInfo.FreeSpace } else { 0 }; DriveC_Total = if ($diskInfo.Size) { $diskInfo.Size } else { 0 } } | ConvertTo-Json -Compress''';

    logger.d('Executing getDashboardInfo command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        logger.e('Received empty response from server for dashboard info.');
        throw Exception('Received empty response from server for dashboard info.');
      }
      return DashboardInfo.fromJson(jsonDecode(jsonString));
    } catch (e) {
      logger.e('Error getting dashboard info: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceItem>> getServices() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command =
        r'''$ProgressPreference = 'SilentlyContinue'; Get-Service | Select-Object ServiceName, DisplayName, Status | ConvertTo-Json -Compress''';
    logger.d('Executing getServices command...');
    try {
      final jsonString = await _execute(command);
       if (jsonString.isEmpty) {
        logger.e('Received empty response from server for services.');
        throw Exception('Received empty response from server for services.');
      }
      // Handle the case where a single JSON object is returned
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [ServiceItem.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ServiceItem.fromJson(json)).toList();
    } catch (e) {
      logger.e('Error getting services: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateServiceStatus(String serviceName, ServiceAction action) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    String command;
    switch (action) {
      case ServiceAction.start:
        command = "Start-Service -Name '$serviceName'";
        break;
      case ServiceAction.stop:
        command = "Stop-Service -Name '$serviceName' -Force";
        break;
      case ServiceAction.restart:
        command = "Restart-Service -Name '$serviceName' -Force";
        break;
    }

    logger.d('Executing service action command: $command');
    try {
      final output = await _execute(command);
      logger.i('Service action completed. Output: $output');
    } catch (e) {
      logger.e('Error updating service status: $e');
      rethrow;
    }
  }

  Future<String> _execute(String command) async {
    logger.d('Executing command: $command');
    // PowerShell's -EncodedCommand expects a Base64-encoded string of a UTF-16LE command.
    final List<int> commandBytes = [];
    for (final codeUnit in command.codeUnits) {
      commandBytes.add(codeUnit & 0xFF);
      commandBytes.add(codeUnit >> 8);
    }
    final base64Command = base64.encode(commandBytes);

    final session = await _client!.execute('powershell -NoProfile -EncodedCommand $base64Command');
    final output = await utf8.decodeStream(session.stdout);
    final error = await utf8.decodeStream(session.stderr);

    if (error.isNotEmpty) {
      logger.e('PowerShell Error: $error');
      throw Exception('PowerShell Error: $error');
    }
    return output.trim();
  }

  @override
  void disconnect() {
    if (isConnected) {
      logger.i('Disconnecting...');
      _client?.close();
      _client = null;
    }
  }
}