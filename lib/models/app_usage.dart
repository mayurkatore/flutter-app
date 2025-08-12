class AppUsage {
  final String id;
  final String appName;
  final String packageName;
  final Duration todayUsage;
  final Duration weeklyUsage;
  final Duration dailyLimit;
  final bool isBlocked;
  final DateTime lastUsed;

  AppUsage({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.todayUsage,
    required this.weeklyUsage,
    required this.dailyLimit,
    required this.isBlocked,
    required this.lastUsed,
  });

  AppUsage copyWith({
    String? id,
    String? appName,
    String? packageName,
    Duration? todayUsage,
    Duration? weeklyUsage,
    Duration? dailyLimit,
    bool? isBlocked,
    DateTime? lastUsed,
  }) {
    return AppUsage(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      todayUsage: todayUsage ?? this.todayUsage,
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      isBlocked: isBlocked ?? this.isBlocked,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  String toString() {
    return 'AppUsage(id: $id, appName: $appName, packageName: $packageName, todayUsage: $todayUsage, weeklyUsage: $weeklyUsage, dailyLimit: $dailyLimit, isBlocked: $isBlocked, lastUsed: $lastUsed)';
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appName': appName,
      'packageName': packageName,
      'todayUsage': todayUsage.inSeconds,
      'weeklyUsage': weeklyUsage.inSeconds,
      'dailyLimit': dailyLimit.inSeconds,
      'isBlocked': isBlocked,
      'lastUsed': lastUsed.toIso8601String(),
    };
  }
  
  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      id: map['id'],
      appName: map['appName'],
      packageName: map['packageName'],
      todayUsage: Duration(seconds: map['todayUsage']),
      weeklyUsage: Duration(seconds: map['weeklyUsage']),
      dailyLimit: Duration(seconds: map['dailyLimit']),
      isBlocked: map['isBlocked'],
      lastUsed: DateTime.parse(map['lastUsed']),
    );
  }
}