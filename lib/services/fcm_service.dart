import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Notification background: ${message.notification?.title}');
}

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu: ${message.notification?.title}');
    });
  }

  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
