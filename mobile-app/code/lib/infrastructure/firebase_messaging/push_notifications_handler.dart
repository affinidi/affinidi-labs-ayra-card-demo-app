import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../loggers/app_logger/app_logger.dart';
import '../providers/app_logger_provider.dart';
import 'firebase_messaging.dart';
import 'push_notification.dart';

part 'push_notifications_handler.g.dart';

/// A Riverpod provider class that handles push notifications lifecycle,
/// device token updates, and notification streams.
@Riverpod(keepAlive: true)
class PushNotificationsHandler extends _$PushNotificationsHandler {
  PushNotificationsHandler() : super();

  /// Emits new push device tokens when refreshed.
  final StreamController<String> _deviceTokenRefreshController =
      StreamController<String>.broadcast();
  Stream<String> get onDeviceTokenRefresh =>
      _deviceTokenRefreshController.stream;

  /// Emits notifications when the user opens them.
  final StreamController<PushNotification> _notificationOpenedController =
      StreamController<PushNotification>.broadcast();
  Stream<PushNotification> get onPushNotificationOpened =>
      _notificationOpenedController.stream;

  /// Emits notifications received while the app is in the foreground.
  final StreamController<PushNotification> _notificationReceivedController =
      StreamController<PushNotification>.broadcast();
  Stream<PushNotification> get onPushNotificationReceived =>
      _notificationReceivedController.stream;

  /// Emits events whenever notifications are processed internally.
  final StreamController<void> _processEventsController =
      StreamController<void>.broadcast();
  Stream<void> get onProcessEvents => _processEventsController.stream;

  final _requiredPermissions = [
    _Permissions.alert,
    _Permissions.badge,
    _Permissions.sound,
  ];

  late final FirebaseMessaging _firebaseMessaging;
  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'PSHNTFYSVC';

  @override
  Future<void> build() async {
    _firebaseMessaging = await ref.read(firebaseMessagingProvider.future);

    // Subscribe to push notification token changes
    _firebaseMessaging.onTokenRefresh.listen((String newDeviceToken) async {
      _logger.info(
        'Device token refreshed: '
        '$newDeviceToken',
        name: _logKey,
      );
      _logger.info(
        'Initiating device re-registration with new token',
        name: _logKey,
      );
      _deviceTokenRefreshController.add(newDeviceToken);
    });

    // Subscribe to new messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.info('Push notification received in foreground', name: _logKey);
      _logger.debug('Push notification data: ${message.data}', name: _logKey);
      final notification = PushNotification.fromPayload(message.data);
      _logger.info(
        'Processing push notification for recipient: '
        '${notification.data.did}',
        name: _logKey,
      );
      await _processNotifications(notification);
      _notificationReceivedController.add(notification);
    });

    unawaited(
      Future(() async {
        _requestPermissions();
        await _requestIOSAPNSToken();
        await _getToken();
        await _setupInteractedMessage();
      }),
    );
  }

  Future<void> _getToken() async {
    await _firebaseMessaging.getToken().then(
      (String? newDeviceToken) async {
        _logger.info(
          'Initial PushToken: ${newDeviceToken ?? 'empty'}',
          name: _logKey,
        );

        if (newDeviceToken == null) {
          _logger.warning(
            'No device token received during initialization',
            name: _logKey,
          );
          return;
        }

        _logger.info(
          'Device token received successfully, initiating registration',
          name: _logKey,
        );
        _deviceTokenRefreshController.add(newDeviceToken);
      },
      onError: (dynamic error) {
        _logger.error(
          'Error while getting initial PushToken',
          error: error,
          name: _logKey,
        );
      },
    );
  }

  void _requestPermissions() {
    unawaited(
      _firebaseMessaging
          .requestPermission(
            alert: _hasPermission(_Permissions.alert),
            badge: _hasPermission(_Permissions.badge),
            sound: _hasPermission(_Permissions.sound),
          )
          .then((settings) {
            _logger.info(
              'User granted permission: ${settings.authorizationStatus}',
              name: _logKey,
            );
            _enableiOSForegroundNotifications();
          }),
    );
  }

  Future<void> _requestIOSAPNSToken() async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final maxAttempts = 5;
    var attempt = 0;
    var delayMs = 500;

    while (attempt < maxAttempts) {
      _logger.info('getAPNSToken attempt $attempt', name: _logKey);

      // For apple platforms, ensure the APNS token is available
      // before making any FCM plugin API calls
      final token = await FirebaseMessaging.instance.getAPNSToken();

      if (token != null) {
        return;
      }

      attempt++;
      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // exponential backoff
      } else {
        _logger.error(
          'Unable to initialize FirebaseMessaging, missing apnsToken',
          name: _logKey,
        );
      }
    }
  }

  Future<void> _enableiOSForegroundNotifications() async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final isForegroundNotificationsEnabled = ref
        .read(environmentProvider)
        .isForegroundNotificationsEnabled;
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert:
          isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.alert),
      badge:
          isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.badge),
      sound:
          isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.sound),
    );
  }

  /// Sets up handling for push notifications opened
  /// when the app is in background or terminated state.
  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    var initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      await _handleOpeningNotification(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpeningNotification);
  }

  /// Handles notifications opened by the user.
  Future<void> _handleOpeningNotification(RemoteMessage message) async {
    _logger.info('Handling message $message', name: _logKey);
    final notification = PushNotification.fromPayload(message.data);
    await _processNotifications(notification);
    _notificationOpenedController.add(notification);
  }

  /// Processes incoming notifications, updates contacts,
  /// and sets the app badge count if required.
  Future<void> _processNotifications(PushNotification notification) async {
    final recipientDid = notification.data.did;
    _logger.info(
      'Processing ${notification.type.name} notification for DID: '
      '$recipientDid',
      name: _logKey,
    );

    _processEventsController.add(null);
    _logger.info(
      'Push notification processing completed successfully',
      name: _logKey,
    );
  }

  /// Checks if the given [_Permissions] is in the required list.
  bool _hasPermission(_Permissions permission) =>
      _requiredPermissions.contains(permission);
}

enum _Permissions { alert, badge, sound }
