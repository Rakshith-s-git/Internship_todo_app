import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  static Future<void> showPriorityNotification({
    required String title,
    required String body,
    required String priority,
  }) async {
    final importance = priority == 'high'
        ? Importance.max
        : priority == 'medium'
        ? Importance.high
        : Importance.defaultImportance;

    final androidDetails = AndroidNotificationDetails(
      'todo_priority_channel',
      'Todo Priority Notifications',
      importance: importance,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
