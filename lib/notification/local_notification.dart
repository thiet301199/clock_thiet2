import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;

class LocalNotification {
  static const String _id = '_ID';
  static const String _channel = '_Channel';
  static const String _description = '_Description';

  static setup() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          flutterLocalNotificationsPlugin.cancel(id);
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {});
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      if (notificationAppLaunchDetails?.notificationResponse?.payload !=
          null) {}
    }
  }

  static Future<void> showNotification(
      String? title, String? body, String? payload) async {
    var macPlatformChannelSpecifics =
        const DarwinNotificationDetails(sound: 'alert');
    var platformChannelSpecifics =
        NotificationDetails(macOS: macPlatformChannelSpecifics);
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await flutterLocalNotificationsPlugin.show(
        notificationId,
        '${title ?? 'Say hi!'} ',
        body ?? 'Nice to meet you again!',
        platformChannelSpecifics,
        payload: payload);
    print('showNotification message.data $payload');
  }

  static Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
