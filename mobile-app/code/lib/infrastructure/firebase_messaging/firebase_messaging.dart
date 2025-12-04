// ignore_for_file: unreachable_from_main

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../loggers/app_logger/app_logger.dart';
import 'push_notification.dart';

/// Provides a [FutureProvider] for initializing and accessing
///  [FirebaseMessaging].
///
/// Sets up background message handling and ensures Firebase is initialized
/// with the correct platform options.
FutureProvider<FirebaseMessaging> firebaseMessagingProvider =
    FutureProvider<FirebaseMessaging>((ref) async {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      return FirebaseMessaging.instance;
    });

/// Background handler for Firebase push notifications.
///
/// Called when a message is received while the app is in the background.
/// Logs the message, parses it into a [PushNotification], and updates
/// the app badge count if supported.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.instance.info(
    'Handling a background message: ${message.messageId}',
    name: 'firebaseMessagingBackgroundHandler',
  );

  final notification = PushNotification.fromPayload(message.data);
  final pendingCount = notification.data.pendingCount ?? 0;

  if (await AppBadgePlus.isSupported()) {
    await AppBadgePlus.updateBadge(pendingCount);
  }
}
