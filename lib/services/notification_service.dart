import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_app_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestAndroidPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permissions
    await androidImplementation?.requestNotificationsPermission();
    
    // Request exact alarm permissions (Android 12+)
    await androidImplementation?.requestExactAlarmsPermission();
    
    if (kDebugMode) {
      final bool? exactAlarmsAllowed = 
          await androidImplementation?.canScheduleExactNotifications();
      print('Exact alarms permission: $exactAlarmsAllowed');
      
      final bool? notificationsAllowed = 
          await androidImplementation?.areNotificationsEnabled();
      print('Notifications permission: $notificationsAllowed');
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('Notification tapped: ${notificationResponse.payload}');
    }
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledDate,
  }) async {
    // Cancel any existing notifications for this task first
    await cancelTaskNotifications(id);
    
    final now = DateTime.now();
    
    // Schedule notification 1 minute before the due time
    final reminderTime = scheduledDate.subtract(const Duration(minutes: 1));
    if (reminderTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id, // Use base ID for reminder
        '🔔 เตือนงาน: $title',
        'งาน "$description" จะถึงกำหนดในอีก 1 นาที ⏰',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'เตือนงานล่วงหน้า',
            channelDescription: 'แจ้งเตือนก่อนถึงกำหนดงาน 1 นาที',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_app_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'task_reminder_$id',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    
    // Schedule notification at the exact due time
    if (scheduledDate.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id + 10000, // Use offset ID for due time notification
        '⏰ ถึงเวลา: $title',
        'งาน "$description" ถึงกำหนดแล้ว! 🚨',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_due_alerts',
            'แจ้งเตือนถึงเวลา',
            channelDescription: 'แจ้งเตือนเมื่องานถึงกำหนดพอดี',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            icon: '@mipmap/ic_app_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: 'task_due_$id',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTaskNotifications(int id) async {
    // Cancel both reminder and due time notifications
    await _flutterLocalNotificationsPlugin.cancel(id); // Reminder notification
    await _flutterLocalNotificationsPlugin.cancel(id + 10000); // Due time notification
  }

  Future<void> cancelTaskReminder(int id) async {
    // Use the new method that cancels both notifications
    await cancelTaskNotifications(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}