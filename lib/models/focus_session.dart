class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final FocusPreset preset;
  final List<String> blockedApps;
  final bool isCompleted;

  FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.preset,
    required this.blockedApps,
    required this.isCompleted,
  });

  // Computed properties
  Duration get elapsedTime {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  bool get isRunning {
    return endTime == null && !isCompleted;
  }

  FocusSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    FocusPreset? preset,
    List<String>? blockedApps,
    bool? isCompleted,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      preset: preset ?? this.preset,
      blockedApps: blockedApps ?? this.blockedApps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'FocusSession(id: $id, startTime: $startTime, endTime: $endTime, duration: $duration, preset: $preset, blockedApps: $blockedApps, isCompleted: $isCompleted)';
  }
}

enum FocusPreset {
  study,
  sleep,
  work,
  custom;

  String get name {
    return toString().split('.').last;
  }
}