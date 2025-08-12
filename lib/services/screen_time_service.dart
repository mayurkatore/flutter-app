import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../models/app_usage.dart';
import 'package:usage_stats/usage_stats.dart';

class ScreenTimeService {
  /// Get screen time statistics for the past 24 hours
  /// This method uses the usage_stats package to fetch actual screen time data from the device
  static Future<List<AppUsage>> getDailyScreenTimeStats() async {
    // This functionality is only available on Android
    if (!Platform.isAndroid) {
      return [];
    }

    try {
      // Check if we have usage permission
      bool granted = await _checkUsagePermission();
      if (!granted) {
        // If permission is not granted, we can't get stats
        return [];
      }

      // Get usage for the past 24 hours
      DateTime end = DateTime.now();
      DateTime start = DateTime(end.year, end.month, end.day)
          .subtract(const Duration(days: 1));
      List<UsageInfo> stats = await UsageStats.queryUsageStats(start, end);

      // Convert UsageInfo to AppUsage
      List<AppUsage> appUsageList = [];
      for (var info in stats) {
        // Skip apps with no usage time
        if (info.totalTimeInForeground == null ||
            info.totalTimeInForeground == '0') {
          continue;
        }

        // Parse the usage time
        int totalTimeMillis =
            int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
        Duration todayUsage = Duration(milliseconds: totalTimeMillis);

        // For weekly usage, we'll use the same value for now
        // In a real implementation, you might want to query a longer period
        Duration weeklyUsage = todayUsage;

        // For daily limit, we'll set a default of 2 hours
        // In a real implementation, this would come from user settings
        Duration dailyLimit = const Duration(hours: 2);

        appUsageList.add(
          AppUsage(
            id: info.packageName ?? '',
            appName: info.packageName ??
                'Unknown App', // Use packageName as appName for now
            packageName: info.packageName ?? '',
            todayUsage: todayUsage,
            weeklyUsage: weeklyUsage,
            dailyLimit: dailyLimit,
            isBlocked: false,
            lastUsed: DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(info.lastTimeUsed ?? '0') ?? 0,
            ),
          ),
        );
      }

      return appUsageList;
    } catch (e) {
      // Handle any errors
      debugPrint('Error getting screen time stats: $e');
      return [];
    }
  }

  /// Request usage permission
  /// This method checks if the usage permission is granted. If not, it indicates
  /// that the user needs to manually enable it in the device settings.
  static Future<bool> requestUsagePermission() async {
    // This functionality is only available on Android
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      bool granted = await _checkUsagePermission();
      if (!granted) {
        // For usage_stats package, we need to guide the user to enable the permission manually
        // The actual permission request needs to be done by the user in Settings
        // We'll just return false here to indicate that the user needs to manually enable it
        return false;
      }
      return granted;
    } catch (e) {
      debugPrint('Error requesting usage permission: $e');
      return false;
    }
  }

  /// Check if we have usage permission
  /// This method uses the usage_stats package to check the actual permission status
  static Future<bool> _checkUsagePermission() async {
    try {
      bool? granted = await UsageStats.checkUsagePermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Error checking usage permission: $e');
      return false;
    }
  }

  /// Format duration in a human-readable way
  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes m';
    } else {
      return '$minutes m';
    }
  }

  /// Get total screen time for the past 24 hours
  static Future<Duration> getTotalScreenTime() async {
    List<AppUsage> stats = await getDailyScreenTimeStats();
    Duration totalTime = Duration.zero;

    for (var info in stats) {
      totalTime += info.todayUsage;
    }

    return totalTime;
  }
}
