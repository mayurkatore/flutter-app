import 'dart:async';
import 'dart:io';
import 'package:app_usage/app_usage.dart' as app_usage;
import 'package:usage_stats/usage_stats.dart';
import '../utils/logger.dart';
import '../models/app_usage_info.dart';
import 'permission_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class ScreenTimeService {
  static final ScreenTimeService _instance = ScreenTimeService._internal();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._internal();

  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  Timer? _trackingTimer;
  bool _isTracking = false;
  Map<String, Duration> _dailyLimits = {};
  final Map<String, Duration> _currentUsage = {};
  Map<String, String> _appCategories = {};
  bool _focusModeEnabled = false;
  Set<String> _allowedAppsInFocusMode = {};

  static const String _screenTimeDataKey = 'screen_time_data';
  static const String _screenTimeLimitsKey = 'screen_time_limits';
  static const String _screenTimeSettingsKey = 'screen_time_settings';
  static const String _appCategoriesKey = 'app_categories';
  static const String _focusModeSettingsKey = 'focus_mode_settings';

  /// Initialize the screen time service
  Future<bool> init() async {
    Logger.info('Initializing ScreenTimeService');

    try {
      await _storageService.init();

      // Load saved data
      await _loadScreenTimeLimits();
      await _loadScreenTimeSettings();
      await _loadAppCategories();
      await _loadFocusModeSettings();

      Logger.info('ScreenTimeService initialized successfully');
      return true;
    } catch (e) {
      Logger.error('Error initializing ScreenTimeService: $e');
      return false;
    }
  }

  /// Load screen time limits from storage
  Future<void> _loadScreenTimeLimits() async {
    try {
      final data = await _storageService.getData<Map<String, dynamic>>(_screenTimeLimitsKey);
      if (data != null) {
        _dailyLimits = data.map((key, value) => MapEntry(key, Duration(milliseconds: value as int)));
      }
    } catch (e) {
      Logger.error('Error loading screen time limits: $e');
    }
  }

  /// Save screen time limits to storage
  Future<void> _saveScreenTimeLimits() async {
    try {
      final data = _dailyLimits.map((key, value) => MapEntry(key, value.inMilliseconds));
      await _storageService.saveData(_screenTimeLimitsKey, data);
    } catch (e) {
      Logger.error('Error saving screen time limits: $e');
    }
  }

  /// Load screen time settings from storage
  Future<void> _loadScreenTimeSettings() async {
    try {
      final data = await _storageService.getData<Map<String, dynamic>>(_screenTimeSettingsKey);
      if (data != null) {
        // Load any relevant settings here in the future
      }
    } catch (e) {
      Logger.error('Error loading screen time settings: $e');
    }
  }

  /// Load app categories from storage
  Future<void> _loadAppCategories() async {
    try {
      final data = await _storageService.getData(_appCategoriesKey);
      if (data != null) {
        _appCategories = Map<String, String>.from(data);
      }
    } catch (e) {
      Logger.error('Error loading app categories: $e');
    }
  }

  /// Load focus mode settings from storage
  Future<void> _loadFocusModeSettings() async {
    try {
      final data = await _storageService.getData(_focusModeSettingsKey);
      if (data != null) {
        _focusModeEnabled = data['enabled'] ?? false;
        _allowedAppsInFocusMode = Set<String>.from(data['allowedApps'] ?? []);
      }
    } catch (e) {
      Logger.error('Error loading focus mode settings: $e');
    }
  }

  /// Set app category
  Future<void> setAppCategory(String packageName, String category) async {
    try {
      _appCategories[packageName] = category;
      await _storageService.saveData(_appCategoriesKey, _appCategories);
      Logger.debug('Set category for $packageName: $category');
    } catch (e) {
      Logger.error('Error setting app category: $e');
    }
  }

  /// Get app category
  String? getAppCategory(String packageName) {
    return _appCategories[packageName];
  }

  /// Enable focus mode
  Future<void> enableFocusMode(Set<String> allowedApps) async {
    try {
      _focusModeEnabled = true;
      _allowedAppsInFocusMode = allowedApps;
      await _saveFocusModeSettings();
      Logger.info('Focus mode enabled with ${allowedApps.length} allowed apps');
    } catch (e) {
      Logger.error('Error enabling focus mode: $e');
    }
  }

  /// Disable focus mode
  Future<void> disableFocusMode() async {
    try {
      _focusModeEnabled = false;
      await _saveFocusModeSettings();
      Logger.info('Focus mode disabled');
    } catch (e) {
      Logger.error('Error disabling focus mode: $e');
    }
  }

  /// Save focus mode settings
  Future<void> _saveFocusModeSettings() async {
    try {
      await _storageService.saveData(_focusModeSettingsKey, {
        'enabled': _focusModeEnabled,
        'allowedApps': _allowedAppsInFocusMode.toList(),
      });
    } catch (e) {
      Logger.error('Error saving focus mode settings: $e');
    }
  }

  /// Start screen time tracking
  Future<bool> startScreenTimeTracking() async {
    Logger.info('Starting screen time tracking');

    try {
      // Check permissions
      final hasPermission = await PermissionService.hasScreenTimePermission();
      if (!hasPermission) {
        Logger.warning('Screen time permission not granted');
        final granted = await PermissionService.requestScreenTimePermission();
        if (!granted) {
          return false;
        }
      }

      if (_isTracking) {
        Logger.warning('Screen time tracking already active');
        return true;
      }

      // Start periodic tracking
      _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _trackScreenTimeUsage();
      });

      _isTracking = true;
      Logger.info('Screen time tracking started successfully');
      return true;
    } catch (e) {
      Logger.error('Error starting screen time tracking: $e');
      return false;
    }
  }

  /// Stop screen time tracking
  Future<void> stopScreenTimeTracking() async {
    Logger.info('Stopping screen time tracking');

    try {
      _trackingTimer?.cancel();
      _trackingTimer = null;
      _isTracking = false;
      Logger.info('Screen time tracking stopped successfully');
    } catch (e) {
      Logger.error('Error stopping screen time tracking: $e');
    }
  }

  /// Get today's app usage statistics
  Future<List<AppUsageInfo>> getTodayAppUsage() async {
    Logger.debug('Getting today\'s app usage');

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      if (Platform.isAndroid) {
        // Use usage_stats for Android
        final usageStats =
            await UsageStats.queryUsageStats(startOfDay, endOfDay);

        final appUsageList = <AppUsageInfo>[];
        for (final stat in usageStats) {
          final timeInForeground = int.tryParse(stat.totalTimeInForeground ?? '0') ?? 0;
          if (timeInForeground > 0) {
            final packageName = stat.packageName ?? 'Unknown';
            appUsageList.add(AppUsageInfo(
              appName: packageName, // appName is not available in usage_stats
              packageName: packageName,
              usage: Duration(milliseconds: timeInForeground),
              startTime: startOfDay,
              endTime: endOfDay,
              category: _appCategories[packageName],
            ));
          }
        }

        // Sort by usage time (descending)
        appUsageList.sort((a, b) => b.usage.compareTo(a.usage));

        Logger.debug('Retrieved ${appUsageList.length} app usage entries');
        return appUsageList;
      } else {
        // Use app_usage for iOS
        final appUsage = app_usage.AppUsage();
        final usageInfos = await appUsage.getAppUsage(startOfDay, endOfDay);

        final appUsageList = usageInfos
            .map((info) => AppUsageInfo(
                  appName: info.appName,
                  packageName: info.packageName,
                  usage: info.usage,
                  startTime: startOfDay,
                  endTime: endOfDay,
                  category: _appCategories[info.packageName],
                ))
            .toList();

        Logger.debug('Retrieved ${appUsageList.length} app usage entries');
        return appUsageList;
      }
    } catch (e) {
      Logger.error('Error getting today\'s app usage: $e');
      return [];
    }
  }

  /// Get app usage for a specific date range
  Future<List<AppUsageInfo>> getAppUsage(
      DateTime startDate, DateTime endDate) async {
    Logger.debug('Getting app usage from $startDate to $endDate');

    try {
      if (Platform.isAndroid) {
        final usageStats = await UsageStats.queryUsageStats(startDate, endDate);

        final appUsageList = <AppUsageInfo>[];
        for (final stat in usageStats) {
          final timeInForeground = int.tryParse(stat.totalTimeInForeground ?? '0') ?? 0;
          if (timeInForeground > 0) {
            final packageName = stat.packageName ?? 'Unknown';
            appUsageList.add(AppUsageInfo(
              appName: packageName, // appName is not available in usage_stats
              packageName: packageName,
              usage: Duration(milliseconds: timeInForeground),
              startTime: startDate,
              endTime: endDate,
              category: _appCategories[packageName],
            ));
          }
        }

        appUsageList.sort((a, b) => b.usage.compareTo(a.usage));
        return appUsageList;
      } else {
        final appUsage = app_usage.AppUsage();
        final List<app_usage.AppUsageInfo> usageInfos =
            await appUsage.getAppUsage(startDate, endDate);
        final appUsageList = usageInfos
            .map((info) => AppUsageInfo(
                  appName: info.appName,
                  packageName: info.packageName,
                  usage: info.usage,
                  startTime: startDate,
                  endTime: endDate,
                  category: _appCategories[info.packageName],
                ))
            .toList();

        return appUsageList;
      }
    } catch (e) {
      Logger.error('Error getting app usage: $e');
      return [];
    }
  }

  /// Set daily limit for an app
  Future<void> setAppLimit(String packageName, Duration limit) async {
    Logger.info('Setting limit for $packageName: ${limit.inMinutes} minutes');

    try {
      _dailyLimits[packageName] = limit;
      await _saveScreenTimeLimits();
      Logger.info('App limit set successfully');
    } catch (e) {
      Logger.error('Error setting app limit: $e');
    }
  }

  /// Remove limit for an app
  Future<void> removeAppLimit(String packageName) async {
    Logger.info('Removing limit for $packageName');

    try {
      _dailyLimits.remove(packageName);
      await _saveScreenTimeLimits();
      Logger.info('App limit removed successfully');
    } catch (e) {
      Logger.error('Error removing app limit: $e');
    }
  }

  /// Get current limits
  Map<String, Duration> get appLimits => Map.from(_dailyLimits);

  /// Check if any app has exceeded its limit
  Future<List<String>> checkLimitExceeded() async {
    Logger.debug('Checking for exceeded limits');

    try {
      final exceededApps = <String>[];
      final todayUsage = await getTodayAppUsage();

      for (final usage in todayUsage) {
        final limit = _dailyLimits[usage.packageName];
        if (limit != null && usage.usage > limit) {
          exceededApps.add(usage.packageName);
          Logger.warning(
              'App ${usage.packageName} exceeded limit: ${usage.usage.inMinutes}/${limit.inMinutes} minutes');
        }
      }

      return exceededApps;
    } catch (e) {
      Logger.error('Error checking limit exceeded: $e');
      return [];
    }
  }

  /// Get total screen time for today
  Future<Duration> getTotalScreenTime([DateTime? date]) async {
    Logger.debug('Getting total screen time');

    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appUsage = await getAppUsage(startOfDay, endOfDay);

      Duration totalTime = Duration.zero;
      for (final usage in appUsage) {
        totalTime += usage.usage;
      }

      Logger.debug('Total screen time: ${totalTime.inMinutes} minutes');
      return totalTime;
    } catch (e) {
      Logger.error('Error getting total screen time: $e');
      return Duration.zero;
    }
  }

  /// Get screen time statistics for the week
  Future<Map<String, Duration>> getWeeklyScreenTime() async {
    Logger.debug('Getting weekly screen time statistics');

    try {
      final now = DateTime.now();
      final weeklyStats = <String, Duration>{};

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dayName = _getDayName(date.weekday);
        final screenTime = await getTotalScreenTime(date);
        weeklyStats[dayName] = screenTime;
      }

      Logger.debug('Weekly screen time stats: $weeklyStats');
      return weeklyStats;
    } catch (e) {
      Logger.error('Error getting weekly screen time: $e');
      return {};
    }
  }

  /// Get most used apps today
  Future<List<AppUsageInfo>> getMostUsedApps([int limit = 10]) async {
    Logger.debug('Getting most used apps (limit: $limit)');

    try {
      final todayUsage = await getTodayAppUsage();

      if (todayUsage.length <= limit) {
        return todayUsage;
      }

      return todayUsage.sublist(0, limit);
    } catch (e) {
      Logger.error('Error getting most used apps: $e');
      return [];
    }
  }

  /// Track screen time usage (called periodically)
  Future<void> _trackScreenTimeUsage() async {
    try {
      final todayUsage = await getTodayAppUsage();

      // Update current usage tracking
      _currentUsage.clear();
      for (final usage in todayUsage) {
        _currentUsage[usage.packageName] = usage.usage;
      }

      // Check for exceeded limits and notify
      final exceededApps = await checkLimitExceeded();
      for (final appPackage in exceededApps) {
        await _notifyLimitExceeded(appPackage);
      }

      // Save usage data
      await _saveScreenTimeData(todayUsage);

      Logger.debug('Screen time tracking completed');
    } catch (e) {
      Logger.error('Error tracking screen time usage: $e');
    }
  }

  /// Notify when app limit is exceeded
  Future<void> _notifyLimitExceeded(String packageName) async {
    try {
      final usage = _currentUsage[packageName] ?? Duration.zero;
      final limit = _dailyLimits[packageName] ?? Duration.zero;

      await _notificationService.showNotification(
        id: packageName.hashCode,
        title: 'App Limit Exceeded',
        body:
            'You\'ve exceeded your daily limit for $packageName (${usage.inMinutes}/${limit.inMinutes} minutes)',
        payload: 'limit_exceeded:$packageName',
      );

      Logger.info('Limit exceeded notification sent for $packageName');
    } catch (e) {
      Logger.error('Error sending limit exceeded notification: $e');
    }
  }

  /// Save screen time data
  Future<void> _saveScreenTimeData(List<AppUsageInfo> usageData) async {
    try {
      final dataMap = usageData
          .map((usage) => usage.toJson())
          .toList();

      await _storageService.saveData(_screenTimeDataKey, dataMap);
      Logger.debug('Screen time data saved');
    } catch (e) {
      Logger.error('Error saving screen time data: $e');
    }
  }

  /// Request screen time permission from the user
  Future<bool> requestUsagePermission() async {
    return await PermissionService.requestScreenTimePermission();
  }

  /// Format duration into a readable string (e.g., 1h 23m)
  String formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    }
    if (duration.inHours < 1) {
      return '${duration.inMinutes}m';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Get daily screen time statistics
  Future<Map<String, Duration>> getDailyScreenTimeStats() async {
    Logger.debug('Getting daily screen time stats');
    try {
      final todayUsage = await getTodayAppUsage();
      final stats = <String, Duration>{};
      for (final usage in todayUsage) {
        stats[usage.appName] = usage.usage;
      }
      return stats;
    } catch (e) {
      Logger.error('Error getting daily screen time stats: $e');
      return {};
    }
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Clear all screen time data
  Future<void> clearScreenTimeData() async {
    Logger.info('Clearing all screen time data');

    try {
      await _storageService.saveScreenTimeLimits({});

      _dailyLimits.clear();
      _currentUsage.clear();

      Logger.info('Screen time data cleared successfully');
    } catch (e) {
      Logger.error('Error clearing screen time data: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    Logger.info('Disposing ScreenTimeService');
    await stopScreenTimeTracking();
  }
}
