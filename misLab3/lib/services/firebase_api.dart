import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class FirebaseApi {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint('FCM Token: $token');
    }

    await _initPushNavigationHandlers();
  }

  Future<void> _initPushNavigationHandlers() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    _handleMessage(initialMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed('/notification');
  }
}
