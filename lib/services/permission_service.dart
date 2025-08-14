import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    Logger.info('Requesting location permission');
    
    try {
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        Logger.info('Location permission granted');
        return true;
      } else if (status.isDenied) {
        Logger.warning('Location permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Location permission permanently denied');
        await openAppSettingsForPermission();
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error requesting location permission: $e');
      return false;
    }
  }

  /// Request background location permission (Android 10+)
  static Future<bool> requestBackgroundLocationPermission() async {
    Logger.info('Requesting background location permission');
    
    try {
      // First ensure we have location permission
      final locationGranted = await requestLocationPermission();
      if (!locationGranted) {
        Logger.warning('Cannot request background location without basic location permission');
        return false;
      }

      final status = await Permission.locationAlways.request();
      
      if (status.isGranted) {
        Logger.info('Background location permission granted');
        return true;
      } else if (status.isDenied) {
        Logger.warning('Background location permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Background location permission permanently denied');
        await openAppSettingsForPermission();
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error requesting background location permission: $e');
      return false;
    }
  }

  /// Request screen time/usage stats permission
  static Future<bool> requestScreenTimePermission() async {
    Logger.info('Requesting screen time permission');
    
    try {
      final status = await Permission.systemAlertWindow.request();
      
      if (status.isGranted) {
        Logger.info('Screen time permission granted');
        return true;
      } else if (status.isDenied) {
        Logger.warning('Screen time permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Screen time permission permanently denied');
        await openAppSettingsForPermission();
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error requesting screen time permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking location permission: $e');
      return false;
    }
  }

  /// Check if background location permission is granted
  static Future<bool> hasBackgroundLocationPermission() async {
    try {
      final status = await Permission.locationAlways.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking background location permission: $e');
      return false;
    }
  }

  /// Check if screen time permission is granted
  static Future<bool> hasScreenTimePermission() async {
    try {
      final status = await Permission.systemAlertWindow.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking screen time permission: $e');
      return false;
    }
  }

  /// Request all necessary permissions for the app
  static Future<Map<String, bool>> requestAllPermissions() async {
    Logger.info('Requesting all app permissions');
    
    final results = <String, bool>{};
    
    // Request location permission
    results['location'] = await requestLocationPermission();
    
    // Request background location if location is granted
    if (results['location'] == true) {
      results['backgroundLocation'] = await requestBackgroundLocationPermission();
    } else {
      results['backgroundLocation'] = false;
    }
    
    // Request screen time permission
    results['screenTime'] = await requestScreenTimePermission();
    
    // Request notification permission
    results['notifications'] = await requestNotificationPermission();
    
    Logger.info('Permission request results: $results');
    return results;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    Logger.info('Requesting notification permission');
    
    try {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        Logger.info('Notification permission granted');
        return true;
      } else if (status.isDenied) {
        Logger.warning('Notification permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Notification permission permanently denied');
        await openAppSettingsForPermission();
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking notification permission: $e');
      return false;
    }
  }

  /// Get the status of all permissions
  static Future<Map<String, PermissionStatus>> getAllPermissionStatuses() async {
    Logger.debug('Getting all permission statuses');
    
    try {
      final permissions = [
        Permission.location,
        Permission.locationAlways,
        Permission.notification,
        Permission.systemAlertWindow,
      ];
      
      final statuses = await permissions.request();
      
      final result = <String, PermissionStatus>{};
      result['location'] = statuses[Permission.location] ?? PermissionStatus.denied;
      result['backgroundLocation'] = statuses[Permission.locationAlways] ?? PermissionStatus.denied;
      result['notifications'] = statuses[Permission.notification] ?? PermissionStatus.denied;
      result['screenTime'] = statuses[Permission.systemAlertWindow] ?? PermissionStatus.denied;
      
      Logger.debug('Permission statuses: $result');
      return result;
    } catch (e) {
      Logger.error('Error getting permission statuses: $e');
      return {};
    }
  }

  /// Check usage access permission (Android specific)
  static Future<bool> checkUsageAccessPermission() async {
    Logger.info('Checking usage access permission');
    try {
      final status = await Permission.systemAlertWindow.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking usage access permission: $e');
      return false;
    }
  }

  /// Request usage access permission with context
  static Future<bool> requestUsageAccessPermission(dynamic context) async {
    Logger.info('Requesting usage access permission');
    try {
      return await requestScreenTimePermission();
    } catch (e) {
      Logger.error('Error requesting usage access permission: $e');
      return false;
    }
  }

  /// Open app settings for manual permission management
  static Future<bool> openAppSettingsForPermission() async {
    Logger.info('Opening app settings for manual permission management');
    try {
      return await openAppSettings();
    } catch (e) {
      Logger.error('Error opening app settings: $e');
      return false;
    }
  }
}