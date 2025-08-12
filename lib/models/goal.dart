class Goal {
  final String id;
  final String title;
  final String reason; // health, study, sleep, etc.
  final Duration weeklyLimit;
  final Duration timeSaved;
  final DateTime startDate;
  final bool isActive;
  final GoalCategory category;

  Goal({
    required this.id,
    required this.title,
    required this.reason,
    required this.weeklyLimit,
    required this.timeSaved,
    required this.startDate,
    required this.isActive,
    required this.category,
  });

  // Computed properties
  Duration get remainingTime {
    return weeklyLimit - timeSaved;
  }

  double get progressPercentage {
    if (weeklyLimit.inMinutes == 0) return 0.0;
    return (timeSaved.inMinutes / weeklyLimit.inMinutes).clamp(0.0, 1.0);
  }

  Goal copyWith({
    String? id,
    String? title,
    String? reason,
    Duration? weeklyLimit,
    Duration? timeSaved,
    DateTime? startDate,
    bool? isActive,
    GoalCategory? category,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      timeSaved: timeSaved ?? this.timeSaved,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, reason: $reason, weeklyLimit: $weeklyLimit, timeSaved: $timeSaved, startDate: $startDate, isActive: $isActive, category: $category)';
  }
}

enum GoalCategory {
  socialMedia,
  entertainment,
  productivity,
  custom,
}