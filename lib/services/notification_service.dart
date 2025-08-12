import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    Logger.info('Initializing NotificationService');
    
    // Initialize timezone data
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon');
        
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
        
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        Logger.info('Notification clicked: ${response.payload}');
      },
    );
    
    _initialized = true;
    Logger.info('NotificationService initialized successfully');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      Logger.warning('NotificationService not initialized, initializing now');
      await init();
    }
    
    Logger.debug('Showing notification: $title');
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'unplug_channel',
      'Unplug Notifications',
      channelDescription: 'Notifications for the Unplug app',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
        
    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
    
    Logger.info('Notification shown successfully: $title');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) {
      Logger.warning('NotificationService not initialized, initializing now');
      await init();
    }
    
    Logger.debug('Scheduling notification: $title for $scheduledTime');
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'unplug_scheduled_channel',
      'Unplug Scheduled Notifications',
      channelDescription: 'Scheduled notifications for the Unplug app',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
        
    // Convert DateTime to TZDateTime
    final tzLocation = tz.getLocation(tz.local.name);
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tzLocation);
        
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    Logger.info('Notification scheduled successfully: $title');
  }

  Future<void> cancelNotification(int id) async {
    Logger.debug('Cancelling notification: $id');
    await _notificationsPlugin.cancel(id);
    Logger.info('Notification cancelled successfully: $id');
  }

  Future<void> cancelAllNotifications() async {
    Logger.debug('Cancelling all notifications');
    await _notificationsPlugin.cancelAll();
    Logger.info('All notifications cancelled successfully');
  }

  Future<void> showFocusModeNotification({
    required int id,
    required Duration timeLeft,
  }) async {
    final minutes = timeLeft.inMinutes;
    final seconds = timeLeft.inSeconds % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';
    
    await showNotification(
      id: id,
      title: 'Focus Mode Active',
      body: 'Time remaining: $timeString',
      payload: 'focus_mode',
    );
  }

  Future<void> showChallengeReminder({
    required int id,
    required String challengeTitle,
  }) async {
    await showNotification(
      id: id,
      title: 'Challenge Reminder',
      body: 'Don\'t forget to complete your "$challengeTitle" challenge today!',
      payload: 'challenge_reminder',
    );
  }

  Future<void> showGoalProgress({
    required int id,
    required String goalTitle,
    required double progress,
  }) async {
    final progressPercent = (progress * 100).round();
    await showNotification(
      id: id,
      title: 'Goal Progress Update',
      body: 'Your goal "$goalTitle" is $progressPercent% complete!',
      payload: 'goal_progress',
    );
  }
}