import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    enableIOSNotifications();
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android:
          AndroidInitializationSettings("@drawable/ic_launcher"),
      iOS: initializationSettingsIOS,
    );

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? message) async {
      if (message != null) {
        // List<String> intentList = message.split('|');
        // CustomNavigator.handleIntents(
        //   intent: intentList.first,
        //   intentType: intentList.last,
        // );
      }
    });

    LocalNotificationService().handleForegroundNotifications();

    LocalNotificationService().handleNotificationOnKilledState();

    // FirebaseMessaging.instance.getToken().then((value) => print(dvalue.toString()));

  }

  static void enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "pps id",
        "pps channel",
        "this is pps channel",
        importance: Importance.max,
        priority: Priority.high,
      ));

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: '${message.data['intent']}|${message.data['intent_type']}',
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  Future handleNotificationOnKilledState() async {
    final RemoteMessage? onKilledMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (onKilledMessage != null) {
      // CustomNavigator.handleIntents(
      //     intent: onKilledMessage.data["intent"].toString(),
      //     intentType: onKilledMessage.data["intent_type"].toString());
    }
  }

  handleForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // CustomNavigator.handleIntents(
      //   intent: message.data["intent"].toString(),
      //   intentType: message.data["intent_type"].toString(),
      // );
    });
  }

}
