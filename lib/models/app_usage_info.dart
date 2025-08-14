class AppUsageInfo {
  final String packageName;
  final String appName;
  final Duration usage;
  final DateTime startTime;
  final DateTime endTime;
  final String? category;

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.usage,
    required this.startTime,
    required this.endTime,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'usage': usage.inMilliseconds,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'category': category,
      };

  factory AppUsageInfo.fromJson(Map<String, dynamic> json) => AppUsageInfo(
        packageName: json['packageName'],
        appName: json['appName'],
        usage: Duration(milliseconds: json['usage']),
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        category: json['category'],
      );

  @override
  String toString() => '$appName: ${usage.inMinutes} minutes';
}
