import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static const int _waterNotificationId = 99999;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezone data mandatory for scheduled notifications
      tz.initializeTimeZones();

      // Dynamically resolve device local timezone
      final timeZoneResult = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneResult.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      AppLogger.info('Timezone set to $timeZoneName');
    } catch (e) {
      AppLogger.error('Failed to set dynamic timezone, falling back to UTC', e);
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // 2. Init platform settings
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    try {
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          AppLogger.info('Notification clicked: ${details.payload}');
        },
      );
      _isInitialized = true;
      AppLogger.info('NotificationService successfully initialized.');
    } catch (e, stack) {
      AppLogger.error(
        'CRITICAL ERROR initializing NotificationService',
        e,
        stack,
      );
      // Set to true anyway to avoid constant re-trying and re-failing loop
      _isInitialized = true;
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;

    final platform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform != null) {
      final androidGranted = await platform.requestNotificationsPermission();
      granted = androidGranted ?? false;
    }

    final iosPlatform = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlatform != null) {
      final iosGranted = await iosPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = iosGranted ?? false;
    }

    AppLogger.info('Notification permission result: $granted');
    return granted;
  }

  /// Generates deterministic stable ID for repeatable scheduling based on habit UUID strings
  int _getDeterministicId(String uniqueString) {
    return uniqueString.hashCode.abs();
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required TimeOfDay time,
  }) async {
    final id = _getDeterministicId(habitId);
    final now = DateTime.now();
    var scheduleDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    final tzDate = tz.TZDateTime.from(scheduleDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'habits_channel',
      'Habit Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Habit Reminder',
      'Time for your habit: $title',
      tzDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'habit_$habitId',
    );
  }

  Future<void> scheduleWaterReminder(int intervalHours) async {
    const int waterId = _waterNotificationId;

    const androidDetails = AndroidNotificationDetails(
      'water_channel',
      'Water Reminders',
      importance: Importance.low,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.periodicallyShow(
      waterId,
      'Stay Hydrated!',
      'It is time to drink some water.',
      intervalHours == 1
          ? RepeatInterval.hourly
          : RepeatInterval.daily, // Rough fallback logic
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(String uniqueKey) async {
    final id = _getDeterministicId(uniqueKey);
    await _plugin.cancel(id);
  }

  Future<void> cancelWaterReminder() async {
    await _plugin.cancel(_waterNotificationId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Simple Preference Persistence wrappers
  Future<void> saveReminderPreference(String key, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_$key', isEnabled);
  }

  Future<bool> getReminderPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminder_$key') ?? false;
  }
}
