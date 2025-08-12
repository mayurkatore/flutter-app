import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HealthyHabitsService {
  static const String _prefsKey = 'app_time_limits';
  
  /// Save time limit for an app
  static Future<void> saveAppTimeLimit(String packageName, int timeLimitInMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing limits
    final Map<String, int> limits = await getAppTimeLimits();
    
    // Update with new limit
    limits[packageName] = timeLimitInMinutes;
    
    // Save to shared preferences
    await prefs.setString(_prefsKey, _encodeMap(limits));
  }
  
  /// Get time limit for an app
  static Future<int?> getAppTimeLimit(String packageName) async {
    final Map<String, int> limits = await getAppTimeLimits();
    return limits[packageName];
  }
  
  /// Get all app time limits
  static Future<Map<String, int>> getAppTimeLimits() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? encodedLimits = prefs.getString(_prefsKey);
    if (encodedLimits == null) {
      return {};
    }
    
    return _decodeMap(encodedLimits);
  }
  
  /// Remove time limit for an app
  static Future<void> removeAppTimeLimit(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing limits
    final Map<String, int> limits = await getAppTimeLimits();
    
    // Remove the app
    limits.remove(packageName);
    
    // Save to shared preferences
    await prefs.setString(_prefsKey, _encodeMap(limits));
  }
  
  /// Encode map to string for storage
  static String _encodeMap(Map<String, int> map) {
    final List<String> pairs = [];
    map.forEach((key, value) {
      pairs.add('$key:$value');
    });
    return pairs.join(',');
  }
  
  /// Decode string to map from storage
  static Map<String, int> _decodeMap(String encoded) {
    final Map<String, int> map = {};
    
    if (encoded.isEmpty) {
      return map;
    }
    
    final List<String> pairs = encoded.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        map[parts[0]] = int.parse(parts[1]);
      }
    }
    
    return map;
  }
  
  /// Format minutes into a human-readable string
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes < 1440) { // Less than a day
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hours';
      } else {
        return '$hours hours $remainingMinutes minutes';
      }
    } else {
      final days = minutes ~/ 1440;
      final remainingHours = (minutes % 1440) ~/ 60;
      if (remainingHours == 0) {
        return '$days days';
      } else {
        return '$days days $remainingHours hours';
      }
    }
  }
}