import 'dart:convert';

ServerInfo serverInfoFromJson(String str) => ServerInfo.fromJson(json.decode(str));

String serverInfoToJson(ServerInfo data) => json.encode(data.toJson());

class ServerInfo {
    final String osName;
    final String csModel;
    final int csTotalPhysicalMemory;
    final int osFreePhysicalMemory;
    final int csNumberOfLogicalProcessors;
    final OsUptime osUptime;

    ServerInfo({
        required this.osName,
        required this.csModel,
        required this.csTotalPhysicalMemory,
        required this.osFreePhysicalMemory,
        required this.csNumberOfLogicalProcessors,
        required this.osUptime,
    });

    factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
        osName: json["OsName"],
        csModel: json["CsModel"],
        csTotalPhysicalMemory: json["CsTotalPhysicalMemory"],
        osFreePhysicalMemory: json["OsFreePhysicalMemory"],
        csNumberOfLogicalProcessors: json["CsNumberOfLogicalProcessors"],
        osUptime: OsUptime.fromJson(json["OsUptime"]),
    );

    Map<String, dynamic> toJson() => {
        "OsName": osName,
        "CsModel": csModel,
        "CsTotalPhysicalMemory": csTotalPhysicalMemory,
        "OsFreePhysicalMemory": osFreePhysicalMemory,
        "CsNumberOfLogicalProcessors": csNumberOfLogicalProcessors,
        "OsUptime": osUptime.toJson(),
    };
}

class OsUptime {
    final int ticks;
    final int days;
    final int hours;
    final int minutes;
    final int seconds;
    final int milliseconds;
    final double totalDays;
    final double totalHours;
    final double totalMinutes;
    final double totalSeconds;
    final double totalMilliseconds;

    OsUptime({
        required this.ticks,
        required this.days,
        required this.hours,
        required this.minutes,
        required this.seconds,
        required this.milliseconds,
        required this.totalDays,
        required this.totalHours,
        required this.totalMinutes,
        required this.totalSeconds,
        required this.totalMilliseconds,
    });

    factory OsUptime.fromJson(Map<String, dynamic> json) => OsUptime(
        ticks: json["Ticks"],
        days: json["Days"],
        hours: json["Hours"],
        minutes: json["Minutes"],
        seconds: json["Seconds"],
        milliseconds: json["Milliseconds"],
        totalDays: json["TotalDays"]?.toDouble(),
        totalHours: json["TotalHours"]?.toDouble(),
        totalMinutes: json["TotalMinutes"]?.toDouble(),
        totalSeconds: json["TotalSeconds"]?.toDouble(),
        totalMilliseconds: json["TotalMilliseconds"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "Ticks": ticks,
        "Days": days,
        "Hours": hours,
        "Minutes": minutes,
        "Seconds": seconds,
        "Milliseconds": milliseconds,
        "TotalDays": totalDays,
        "TotalHours": totalHours,
        "TotalMinutes": totalMinutes,
        "TotalSeconds": totalSeconds,
        "TotalMilliseconds": totalMilliseconds,
    };
}
