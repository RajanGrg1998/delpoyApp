import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    bool? initialized = await notificationsPlugin.initialize(
      initializationSettings,
    );
    log('Notifications: $initialized');
  }

  void showNotication() async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'Clip Magic',
      'Merged Clip Notification',
      enableVibration: true,
      priority: Priority.max,
      importance: Importance.max,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      0,
      'Clip Magic Notification',
      'Merged Cliped Saved to Photos Gallery',
      notificationDetails,
      payload: "notification-payload",
    );
  }

  void checkforNotification() async {
    NotificationAppLaunchDetails? appLaunchDetails =
        await notificationsPlugin.getNotificationAppLaunchDetails();

    if (appLaunchDetails != null) {
      if (appLaunchDetails.didNotificationLaunchApp) {
        NotificationResponse? response =
            await appLaunchDetails.notificationResponse;

        if (response != null) {
          String? payload = response.payload;
          log('Notification Payload: $payload');
        }
      }
    }
  }
}
