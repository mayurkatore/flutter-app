class Challenge {
  final String id;
  final String title;
  final String description;
  final int duration; // in days
  final DateTime startDate;
  final List<bool> dailyProgress; // completed days
  final bool isCompleted;
  final String badgeName;
  final ChallengeType type;
  final String? groupId; // Nullable to allow challenges not associated with groups

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.startDate,
    required this.dailyProgress,
    required this.isCompleted,
    required this.badgeName,
    required this.type,
    this.groupId,
  });

  // Computed properties
  int get currentStreak {
    int streak = 0;
    for (int i = dailyProgress.length - 1; i >= 0; i--) {
      if (dailyProgress[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double get progressPercentage {
    if (dailyProgress.isEmpty) return 0.0;
    final completedDays = dailyProgress.where((day) => day).length;
    return completedDays / dailyProgress.length;
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    DateTime? startDate,
    List<bool>? dailyProgress,
    bool? isCompleted,
    String? badgeName,
    ChallengeType? type,
    String? groupId,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      badgeName: badgeName ?? this.badgeName,
      type: type ?? this.type,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, description: $description, duration: $duration, startDate: $startDate, dailyProgress: $dailyProgress, isCompleted: $isCompleted, badgeName: $badgeName, type: $type, groupId: $groupId)';
  }
}

enum ChallengeType {
  daily,
  weekly,
  custom,
}