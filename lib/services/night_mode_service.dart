import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NightModeService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _notificationId = 1;
  static const String _channelId = 'bedtime_channel';
  static const String _channelName = 'Bedtime Reminders';
  static const String _channelDescription = 'Notifications to remind you to avoid screens before bed';

  /// Initialize the notification service
  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon');
        
    // iOS initialization settings
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();
        
    // Initialization settings for both platforms
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
    );
    
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Schedule a bedtime reminder notification
  static Future<void> scheduleBedtimeReminder({
    required TimeOfDay bedtime,
    required String title,
    required String body,
  }) async {
    // Create the notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    // Get the next occurrence of bedtime
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );
    
    // If bedtime today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      _notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the bedtime reminder notification
  static Future<void> cancelBedtimeReminder() async {
    await _notificationsPlugin.cancel(_notificationId);
  }

  /// Check if a bedtime reminder is scheduled
  static Future<bool> isBedtimeReminderScheduled() async {
    final activeNotifications =
        await _notificationsPlugin.getActiveNotifications();
    return activeNotifications.any((notification) => notification.id == _notificationId);
  }
}

/// A simple class to represent time of day
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay(this.hour, this.minute);
}