import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Handler en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Notification background: ${message.notification?.title}');
}

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'medicall_channel',
    'MédiCall Notifications',
    description: 'Notifications de consultations MédiCall',
    importance: Importance.max,
    playSound: true,
  );

  // ── Initialisation complète ────────────────────────────────────────────────
  static Future<void> init() async {
    // Enregistrer le handler background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Demander la permission (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Configurer le canal Android
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialiser les notifications locales
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _localNotif.initialize(initSettings);

    // Afficher les notifications en foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Écouter les messages en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Écouter les taps sur notifications (app en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // ── Récupérer le token FCM ─────────────────────────────────────────────────
  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  // ── Gérer les messages reçus en foreground ─────────────────────────────────
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF1D9E75),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['consultationId'],
    );
  }

  // ── Gérer le tap sur une notification ─────────────────────────────────────
  static void _handleNotificationTap(RemoteMessage message) {
    final consultationId = message.data['consultationId'];
    debugPrint('Notification tappée — consultation: $consultationId');
    // Navigation vers la consultation peut être ajoutée ici via GlobalKey<NavigatorState>
  }

  // ── Envoyer une notification via Firestore trigger ─────────────────────────
  // (Les notifications sont envoyées via Cloud Functions — voir FIREBASE_SETUP.md)

  /// Abonnement à un topic (ex: toutes les urgences)
  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
