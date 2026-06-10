import 'dart:convert';
import 'package:auto/app_database.dart';
import 'package:auto/notifications/data/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:auto/objectbox.g.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Extra High Importance Notifications', // title
    description: 'This channel is used for important notifications like new promotions.', // description
    importance: Importance.max,
  );

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification click
              },
    );

    // Create the channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      // Save to ObjectBox
      final box = ObjectBoxService().box<NotificationObjectBox>();
      final newNotif = NotificationObjectBox(
        title: notification.title,
        body: notification.body,
        type: message.data['type'],
        data: jsonEncode(message.data),
        receivedAt: DateTime.now(),
      );
      box.put(newNotif);

      // Show local notification
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  static int getUnreadCount() {
    final box = ObjectBoxService().box<NotificationObjectBox>();
    final query = box.query(NotificationObjectBox_.isRead.equals(false)).build();
    final count = query.count();
    query.close();
    return count;
  }

  static void markAllAsRead() {
    final box = ObjectBoxService().box<NotificationObjectBox>();
    final notifications = box.getAll();
    for (var n in notifications) {
      n.isRead = true;
    }
    box.putMany(notifications);
  }
}
