import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    'todo_channel',
    'Todo Reminders',
    description: 'Reminder notifications for todos',
    importance: Importance.max,
  );

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final TimezoneInfo localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (e) {
      // Fallback to UTC if device timezone name isn't in the database
      tz.setLocalLocation(tz.UTC);
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings);

    final AndroidFlutterLocalNotificationsPlugin androidPlugin =
    AndroidFlutterLocalNotificationsPlugin();

    await androidPlugin.createNotificationChannel(_channel);
    await androidPlugin.requestNotificationsPermission();
    await androidPlugin.requestExactAlarmsPermission();

    _initialized = true;
  }
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print("TZ time being scheduled: $tzTime");
    print("Current TZ time: ${tz.TZDateTime.now(tz.local)}");
    print("Is in future: ${tzTime.isAfter(tz.TZDateTime.now(tz.local))}");

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Reminders',
          channelDescription: 'Reminder notifications for todos',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),


      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    final pending = await _plugin.pendingNotificationRequests();
    print("Pending after schedule: ${pending.length}");
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> testNotification() async {
    await _plugin.show(
      999,
      "Test Notification",
      "If you see this, notifications work.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> testScheduledNotification() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    await scheduleNotification(
      id: 1000,
      title: "Scheduled Test",
      body: "This should appear in 10 seconds",
      scheduledTime: scheduledTime,
    );
  }
  Future<void> checkPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    print("Total pending: ${pending.length}");
    for (final n in pending) {
      print("Pending → id: ${n.id}, title: ${n.title}, body: ${n.body}");
    }
  }
}