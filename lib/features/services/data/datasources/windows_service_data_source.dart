import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';
import 'package:win_assist/features/services/domain/entities/service_item.dart';
import 'package:win_assist/features/services/domain/entities/service_action.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';

abstract class WindowsServiceDataSource {
  Future<DashboardInfo> getDashboardInfo();
  Future<List<ServiceItem>> getServices();
  Future<void> connect(String ip, int port, String username, String password);
  void disconnect();
  bool get isConnected;

  // Service management
  Future<void> updateServiceStatus(String serviceName, ServiceAction action);

  // User management
  Future<List<WindowsUser>> getLocalUsers();
  Future<void> toggleUserStatus(String username, bool enable);
  Future<void> resetUserPassword(String username, String newPassword);

  // Sessions
  Future<List<WindowsSession>> getRemoteSessions();
  Future<void> killSession(int sessionId);
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

  @override
  Future<List<WindowsUser>> getLocalUsers() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''Get-LocalUser | Select-Object Name,Enabled,LastLogon,Description | ConvertTo-Json -Compress''';
    logger.d('Executing getLocalUsers command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        logger.e('Received empty response from server for local users.');
        throw Exception('Received empty response from server for local users.');
      }

      // Handle single object or list
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [WindowsUser.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WindowsUser.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      logger.e('Error getting local users: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleUserStatus(String username, bool enable) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    final command = enable
        ? "Enable-LocalUser -Name '$username'"
        : "Disable-LocalUser -Name '$username'";

    logger.d('Executing toggleUserStatus command: $command');
    try {
      final output = await _execute(command);
      logger.i('Toggle user status completed. Output: $output');
    } catch (e) {
      logger.e('Error toggling user status: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetUserPassword(String username, String newPassword) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    final command = '\$secPass = ConvertTo-SecureString "${newPassword.replaceAll('"', '\\"')}" -AsPlainText -Force; Set-LocalUser -Name "${username.replaceAll('"', '\\"')}" -Password \$secPass';

    logger.d('Executing resetUserPassword command for $username');
    try {
      final output = await _execute(command);
      logger.i('Reset password completed. Output: $output');
    } catch (e) {
      logger.e('Error resetting user password: $e');
      rethrow;
    }
  }

  // --- Sessions related methods ---
  @override
  Future<List<WindowsSession>> getRemoteSessions() async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    const command = r'''
$quser = quser 2>&1 | Select-Object -Skip 1
if ($quser) {
    $quser | ForEach-Object {
        if ($_ -match '^\s*([^\s]+)\s+(\d+)\s+([^\s]+)') {
            @{ Username = $Matches[1]; Id = [int]$Matches[2]; State = $Matches[3]; }
        } elseif ($_ -match '^\s*>([^\s]+)\s+([^\s]+)\s+(\d+)\s+([^\s]+)') {
            @{ Username = $Matches[1]; Id = [int]$Matches[3]; State = $Matches[4]; }
        }
    } | ConvertTo-Json -Compress
} else { "[]" }
''';

    logger.d('Executing getRemoteSessions command...');
    try {
      final jsonString = await _execute(command);
      if (jsonString.isEmpty) {
        logger.e('Received empty response from server for remote sessions.');
        throw Exception('Received empty response from server for remote sessions.');
      }

      // Handle single object or list
      if (jsonString.startsWith('{')) {
        final Map<String, dynamic> jsonItem = jsonDecode(jsonString);
        return [WindowsSession.fromJson(jsonItem)];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WindowsSession.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      logger.e('Error getting remote sessions: $e');
      rethrow;
    }
  }

  @override
  Future<void> killSession(int sessionId) async {
    if (!isConnected) {
      logger.e('Not connected. Please call connect() first.');
      throw Exception('Not connected. Please call connect() first.');
    }

    final command = 'rwinsta $sessionId'; // or 'logoff $sessionId'
    logger.d('Executing killSession command: $command');
    try {
      final output = await _execute(command);
      logger.i('Kill session completed. Output: $output');
    } catch (e) {
      logger.e('Error killing session: $e');
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