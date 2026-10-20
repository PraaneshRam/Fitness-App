import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    _isInitialized = true;
  }

  // Schedule daily workout reminder
  Future<void> scheduleWorkoutReminder(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('workoutNotifications') ?? true)) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 1, // ID for workout notification
      title: 'Time for Your Workout! 💪',
      body: 'Maintain your streak and stay healthy with today\'s exercises.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel',
          'Workout Reminders',
          channelDescription: 'Daily workout reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.blue,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'workout',
    );
  }

  // Schedule water intake reminders
  Future<void> scheduleWaterReminders() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('waterNotifications') ?? true)) return;

    // Schedule reminders every 2 hours from 8 AM to 8 PM
    final now = DateTime.now();
    for (int hour = 8; hour <= 20; hour += 2) {
      var scheduledDate = DateTime(now.year, now.month, now.day, hour);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: hour, // Using hour as ID
        title: 'Stay Hydrated! 💧',
        body: 'Time to drink some water and stay refreshed!',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'water_channel',
            'Water Reminders',
            channelDescription: 'Water intake reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            color: Colors.blue,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'water',
      );
    }
  }

  // Schedule step goal reminder
  Future<void> scheduleStepGoalReminder() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('stepNotifications') ?? true)) return;

    // Schedule reminder at 6 PM
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      18, // 6 PM
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 100, // ID for step goal notification
      title: 'Step Goal Check! 👣',
      body: 'Check your step count and take a walk if needed to reach your daily goal!',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'step_channel',
          'Step Goal Reminders',
          channelDescription: 'Daily step goal reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.blue,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'steps',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }
}
