# Unplug App - Data Models

## Overview
This document defines the data models that will be used throughout the Unplug application. These models represent the core entities in our digital wellness domain.

## Core Data Models

### 1. AppUsage
Represents usage data for a specific application.

```dart
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

  // Copy with method for immutable updates
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
}
```

### 2. Challenge
Represents a digital wellness challenge that users can participate in.

```dart
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
    );
  }
}

enum ChallengeType {
  daily,
  weekly,
  custom,
}
```

### 3. JournalEntry
Represents a user's journal entry with mood tracking.

```dart
class JournalEntry {
  final String id;
  final DateTime date;
  final Mood mood;
  final String prompt;
  final String response;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.prompt,
    required this.response,
    required this.tags,
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    String? prompt,
    String? response,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      tags: tags ?? this.tags,
    );
  }
}

enum Mood {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}
```

### 4. Goal
Represents a user's digital wellness goal.

```dart
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
}

enum GoalCategory {
  socialMedia,
  entertainment,
  productivity,
  custom,
}
```

### 5. FocusSession
Represents a focus mode session.

```dart
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
}

enum FocusPreset {
  study,
  sleep,
  work,
  custom,
}
```

### 6. User
Represents the app user.

```dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final List<String> interests;
  final List<String> friendIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    required this.interests,
    required this.friendIds,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinDate,
    List<String>? interests,
    List<String>? friendIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      interests: interests ?? this.interests,
      friendIds: friendIds ?? this.friendIds,
    );
  }
}
```

## Data Relationships

### User - AppUsage
- One-to-many: A user has multiple app usage records

### User - Challenge
- One-to-many: A user can participate in multiple challenges

### User - JournalEntry
- One-to-many: A user can have multiple journal entries

### User - Goal
- One-to-many: A user can set multiple goals

### User - FocusSession
- One-to-many: A user can have multiple focus sessions

### Challenge - User (for group challenges)
- Many-to-many: Multiple users can participate in the same challenge

## Data Persistence Strategy

### Local Storage
- SharedPreferences: For simple user preferences and settings
- SQLite: For complex data structures and relationships

### Data Synchronization
- For group challenges and social features, data will be synchronized with a backend when online
- Conflict resolution strategies will be implemented for offline scenarios

## Future Extensions

### Educational Content
- Articles, infographics, and quizzes will be added as additional models

### Peer Groups
- Group models for managing friend groups and shared challenges

### Analytics
- Usage analytics models for tracking long-term trends and insights