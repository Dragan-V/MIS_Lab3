import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:async';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const String _channelId = 'daily_random_recipe';
  static const String _channelName = 'Daily Random Recipe';
  static const String _channelDesc = 'Daily reminder to view the random recipe of the day';

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(0, 'Init', 'Notification channel initialized', details);
    await _plugin.cancel(0);
    _initialized = true;
  }

  Future<void> scheduleDailyAt(int hour, int minute) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);


  print('[NotificationService] Scheduling daily at $hour:$minute -> $scheduled (local=${tz.local})');

  _startDebugCountdown(scheduled);

    await _plugin.zonedSchedule(
      9001,
      'Потсетување',
      'Отвори ја апликацијата и види рандом рецепт на денот',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _startDebugCountdown(tz.TZDateTime target) {
    Timer? ticker;
    ticker = Timer.periodic(const Duration(seconds: 5), (t) {
      final now = tz.TZDateTime.now(tz.local);
      final remaining = target.difference(now);
      if (remaining.isNegative) {
        print('[NotificationService] Countdown reached 0. Notification should fire now/soon.');
        ticker?.cancel();
        return;
      }
      final hrs = remaining.inHours;
      final mins = remaining.inMinutes % 60;
      final secs = remaining.inSeconds % 60;
      print('[NotificationService] Time until notification: ${hrs}h ${mins}m ${secs}s');
    });
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(9001);
  }
}
