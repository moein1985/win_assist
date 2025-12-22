import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:win_assist/models/dashboard_info.dart';
import 'package:win_assist/models/service_item.dart';

class WindowsService {
  SSHClient? _client;

  bool get isConnected => _client != null && !_client!.isClosed;

  Future<void> connect({
    required String ip,
    required int port,
    required String username,
    required String password,
  }) async {
    if (isConnected) {
      debugPrint('Already connected.');
      return;
    }
    debugPrint('Connecting to $ip:$port...');
    try {
      final socket = await SSHSocket.connect(ip, port, timeout: const Duration(seconds: 15));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      // Wait for the client to be ready
      await _client!.authenticated;
      debugPrint('SSH connection successful.');
    } on TimeoutException {
      debugPrint('Connection timed out.');
      _client = null;
      rethrow;
    } catch (e) {
      debugPrint('Connection failed: $e');
      _client = null;
      rethrow;
    }
  }

  Future<DashboardInfo> getDashboardInfo() async {
    if (!isConnected) {
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''
      $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem;
      $csInfo = Get-CimInstance -ClassName Win32_ComputerSystem;
      $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'";

      $output = @{
          OsName = $osInfo.Caption;
          CsModel = $csInfo.Model;
          CsTotalPhysicalMemory = $csInfo.TotalPhysicalMemory;
          OsFreePhysicalMemoryInBytes = [long]($osInfo.FreePhysicalMemory * 1024);
          DriveC_Free = $diskInfo.FreeSpace;
          DriveC_Total = $diskInfo.Size
      }

      $output | ConvertTo-Json -Compress
    ''';

    debugPrint('Executing getDashboardInfo command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        throw Exception('Received empty response from server for dashboard info.');
      }
      return DashboardInfo.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error getting dashboard info: $e');
      rethrow;
    }
  }

  Future<List<ServiceItem>> getServices() async {
    if (!isConnected) {
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = 'Get-Service | Select-Object ServiceName, DisplayName, Status | ConvertTo-Json -Compress';
    debugPrint('Executing getServices command...');
    try {
      final jsonString = await _execute(command);
       if (jsonString.isEmpty) {
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
      debugPrint('Error getting services: $e');
      rethrow;
    }
  }

  Future<String> _execute(String command) async {
    final session = await _client!.execute('powershell -NoProfile -Command "$command"');
    final output = await utf8.decodeStream(session.stdout);
    final error = await utf8.decodeStream(session.stderr);

    if (error.isNotEmpty) {
      throw Exception('PowerShell Error: $error');
    }
    return output.trim();
  }

  void disconnect() {
    if (isConnected) {
      debugPrint('Disconnecting...');
      _client?.close();
      _client = null;
    }
  }
}
