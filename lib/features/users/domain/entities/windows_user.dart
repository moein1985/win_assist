class WindowsUser {
  final String name;
  final bool isEnabled;
  final String? lastLogon;
  final String? description;

  WindowsUser({
    required this.name,
    required this.isEnabled,
    this.lastLogon,
    this.description,
  });

  factory WindowsUser.fromJson(Map<String, dynamic> json) {
    return WindowsUser(
      name: json['Name'] ?? 'N/A',
      isEnabled: json['Enabled'] == true || json['Enabled'] == 'True',
      lastLogon: json['LastLogon']?.toString(),
      description: json['Description']?.toString(),
    );
  }
}
