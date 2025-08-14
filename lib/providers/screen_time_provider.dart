import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/screen_time_service.dart';
import '../models/app_usage_info.dart';
import '../utils/logger.dart';

// Screen time service provider
final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  return ScreenTimeService();
});

/// State class for screen time tracking.
class ScreenTimeTrackingState {
  final bool isTracking;
  final bool hasPermission;
  final Duration totalScreenTime;
  final List<AppUsageInfo> appUsage;
  final Map<String, Duration> appLimits;
  final List<String> exceededApps;

  const ScreenTimeTrackingState({
    this.isTracking = false,
    this.hasPermission = false,
    this.totalScreenTime = Duration.zero,
    this.appUsage = const [],
    this.appLimits = const {},
    this.exceededApps = const [],
  });

  ScreenTimeTrackingState copyWith({
    bool? isTracking,
    bool? hasPermission,
    Duration? totalScreenTime,
    List<AppUsageInfo>? appUsage,
    Map<String, Duration>? appLimits,
    List<String>? exceededApps,
  }) {
    return ScreenTimeTrackingState(
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      appUsage: appUsage ?? this.appUsage,
      appLimits: appLimits ?? this.appLimits,
      exceededApps: exceededApps ?? this.exceededApps,
    );
  }
}

/// Notifier for screen time tracking.
class ScreenTimeTrackingNotifier extends AsyncNotifier<ScreenTimeTrackingState> {
  @override
  Future<ScreenTimeTrackingState> build() async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    final hasPermission = await screenTimeService.init();

    if (!hasPermission) {
      return const ScreenTimeTrackingState(hasPermission: false);
    }

    final appUsage = await screenTimeService.getTodayAppUsage();
    final totalTime = await screenTimeService.getTotalScreenTime();
    final exceededApps = await screenTimeService.checkLimitExceeded();
    final appLimits = screenTimeService.appLimits;

    return ScreenTimeTrackingState(
      hasPermission: true,
      isTracking: screenTimeService.isTracking,
      appUsage: appUsage,
      totalScreenTime: totalTime,
      exceededApps: exceededApps,
      appLimits: appLimits,
    );
  }

  /// Initialize the screen time tracking service.
  Future<void> initialize() async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.init();
    await refreshData();
  }

  /// Refreshes the screen time data.
  Future<void> refreshData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Starts screen time tracking.
  Future<void> startTracking() async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.startScreenTimeTracking();
    await refreshData();
  }

  /// Stops screen time tracking.
  Future<void> stopTracking() async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.stopScreenTimeTracking();
    await refreshData();
  }

  /// Sets an app limit.
  Future<void> setAppLimit(String packageName, Duration limit) async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.setAppLimit(packageName, limit);
    await refreshData();
  }

  /// Removes an app limit.
  Future<void> removeAppLimit(String packageName) async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.removeAppLimit(packageName);
    await refreshData();
  }

  /// Clears all screen time data.
  Future<void> clearAllData() async {
    final screenTimeService = ref.read(screenTimeServiceProvider);
    await screenTimeService.clearScreenTimeData();
    await refreshData();
  }
}

/// Main provider for screen time tracking.
final screenTimeTrackingProvider =
    AsyncNotifierProvider<ScreenTimeTrackingNotifier, ScreenTimeTrackingState>(
  ScreenTimeTrackingNotifier.new,
);

class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
