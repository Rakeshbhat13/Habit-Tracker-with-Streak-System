import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitTitle,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      '⏰ Habit Reminder',
      'Time to complete: $habitTitle',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily habit reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> showBadgeNotification(String badgeTitle, String icon) async {
    await _plugin.show(
      999,
      '$icon Badge Unlocked!',
      'You earned the "$badgeTitle" badge!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'badges',
          'Badge Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
