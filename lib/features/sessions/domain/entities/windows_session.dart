class WindowsSession {
  final int id;
  final String username;
  final String state; // Active, Disc, etc.
  final String? idleTime;
  final String? logonTime;

  WindowsSession({
    required this.id,
    required this.username,
    required this.state,
    this.idleTime,
    this.logonTime,
  });

  factory WindowsSession.fromJson(Map<String, dynamic> json) {
    return WindowsSession(
      id: (json['Id'] as num?)?.toInt() ?? 0,
      username: json['Username'] ?? 'N/A',
      state: json['State'] ?? 'Unknown',
      idleTime: json['IdleTime']?.toString(),
      logonTime: json['LogonTime']?.toString(),
    );
  }
}
