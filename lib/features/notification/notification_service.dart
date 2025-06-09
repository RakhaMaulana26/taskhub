import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskhub/data/models/notification.dart';
import 'package:taskhub/data/db/todo_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleAllPendingNotifications() async {
    final allTodos = await TodoDatabase.instance.readAllTodos();
    for (final todo in allTodos) {
      final notifs = await TodoDatabase.instance.readNotificationsByTodoId(todo.id!);
      for (final notif in notifs) {
        if (!notif.isSent && notif.scheduledTime.isAfter(DateTime.now())) {
          await scheduleNotification(notif, todo.title);
        }
      }
    }
  }

  static Future<void> openExactAlarmSettings() async {
    // Membuka pengaturan exact alarm (khusus Android)
    await Permission.scheduleExactAlarm.request();
    // Atau gunakan openAppSettings() jika ingin langsung ke pengaturan aplikasi
    // await openAppSettings();
  }

  static Future<void> requestExactAlarmPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool('exact_alarm_requested') ?? false;
    if (!alreadyRequested) {
      await Permission.scheduleExactAlarm.request();
      await prefs.setBool('exact_alarm_requested', true);
    }
  }

  static Future<void> scheduleNotification(NotificationModel notif, String todoTitle) async {
    debugPrint('[NOTIF] Mulai penjadwalan notifikasi');
    debugPrint('[NOTIF] Data: id=${notif.id}, todoId=${notif.todoId}, scheduledTime=${notif.scheduledTime}, isSent=${notif.isSent}, todoTitle=$todoTitle');
    try {
      final androidDetails = AndroidNotificationDetails(
        'taskhub_channel',
        'TaskHub Notifications',
        channelDescription: 'Notifikasi tugas dari TaskHub',
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.primary,
        playSound: true,
      );
      final details = NotificationDetails(android: androidDetails);
      debugPrint('[NOTIF] AndroidNotificationDetails dan NotificationDetails berhasil dibuat');
      final scheduledTZ = tz.TZDateTime.from(notif.scheduledTime, tz.getLocation('Asia/Jakarta'));
      debugPrint('[NOTIF] scheduledTime (Asia/Jakarta): $scheduledTZ');
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notif.id ?? notif.scheduledTime.millisecondsSinceEpoch ~/ 1000,
        'Pengingat Tugas',
        todoTitle,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      debugPrint('[NOTIF] Notifikasi berhasil dijadwalkan: id=${notif.id}, waktu=$scheduledTZ, todo=$todoTitle');
    } catch (e, stack) {
      debugPrint('[NOTIF][ERROR] Gagal menjadwalkan notifikasi exact: $e');
      debugPrint('[NOTIF][ERROR] Stacktrace: $stack');
      // Jika error karena exact alarm, arahkan user ke pengaturan
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('[NOTIF][ERROR] exact_alarms_not_permitted, membuka pengaturan exact alarm');
        await openExactAlarmSettings();
      }
    }
  }
}
