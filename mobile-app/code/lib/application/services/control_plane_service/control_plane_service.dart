import 'dart:async';

import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/services/navigation_service.dart';
import '../vdsp_service/vdsp_service.dart';
import 'control_plane_service_state.dart';

part 'control_plane_service.g.dart';

/// Service responsible for processing control plane stream events and device
///  tokens.
///
/// This service:
/// - Subscribes to the MeetingPlaceCoreSDK control plane stream and routes
/// events to domain
/// streams:
///   - onInvitationAccepted
///   - onGroupInvitationAccepted
///   - onConnectionOfferApproved
///   - onChannelInaugurated
/// - Registers the device push token with the SDK and triggers queued event
///   processing.
/// - Observes app lifecycle changes to trigger event processing on resume
///  (clears badges and processes events).
/// - Serializes control plane event processing to avoid concurrent runs.
///
/// The service exposes event streams that other services (ContactsService
/// , ConnectionsService) consume to create/update domain models and UI state
/// . It does not expose public mutation APIs;
/// it acts as an adapter between the SDK control plane feed,
/// push notifications, and app-level services.
@Riverpod(keepAlive: true)
class ControlPlaneService extends _$ControlPlaneService
    with WidgetsBindingObserver {
  ControlPlaneService() : super();
  static const _logKey = 'CTLPLNSVC';

  // Stream<ControlPlaneStreamEvent>? _controlPlaneEventsStream;
  late final AppLogger _logger = ref.read(appLoggerProvider);

  MeetingPlaceCoreSDK? _sdk;

  // var _tokenReceived = false;

  @override
  ControlPlaneServiceState build() {
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    // ref
    //     .read(pushNotificationsHandlerProvider.notifier)
    //     .onDeviceTokenRefresh
    //     .listen((token) {
    //       Future(() => _registerDeviceToken(token));
    //     });

    // ref.read(pushNotificationsHandlerProvider.notifier).onProcessEvents.listen((
    //   _,
    // ) {
    //   Future(_processEvents);
    // });

    ref.read(mpxSdkProvider.future).then((sdk) async {
      if (_sdk != null) return;
      _sdk = sdk;
      // _controlPlaneEventsStream = sdk.controlPlaneEventsStream;
      // _controlPlaneEventsStream?.listen(_handleControlPlaneEvent);
    });

    return const ControlPlaneServiceState();
  }

  /// Initialize VDSP request listener for incoming verifiable data sharing
  /// requests.
  ///
  /// This sets up a listener that monitors for incoming VDSP requests on the
  /// holder's DID. The listener handles the complete flow of credential
  /// sharing including progress updates, user confirmation (via
  /// NavigationService), and completion callbacks.
  ///
  /// The listener uses NavigationService to show consent and result screens
  /// globally, so it works from any screen in the app.
  ///
  /// Throws:
  /// - Propagates any exceptions from VDSP service initialization.
  Future<void> initializeVdspListener() async {
    try {
      _logger.info('Initializing VDSP request listener', name: _logKey);

      final holderChannelDid =
          'did:key:zDnaeunsrd8Bg2R9KqMc7mzdkVG3Mm1CYCfKeK35rLPKdjjyA';

      _logger.info('Holder Channel DID: $holderChannelDid', name: _logKey);

      final vdspService = ref.read(vdspServiceProvider);

      // Subscribe to VDSP requests using NavigationService for UI
      await vdspService.subscribeForVdspRequests(
        onlyOnce: false,
        holderChannelDid: holderChannelDid,
        onProgress: (String msg) async {
          _logger.info('VDSP Progress: $msg', name: _logKey);
        },
        onShareConfirmation: NavigationService.showConsentBottomSheet,
        onComplete: NavigationService.showResultBottomSheet,
      );

      _logger.info(
        'VDSP request listener initialized successfully',
        name: _logKey,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize VDSP request listener',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  /// Dispose VDSP request listener and stop connections.
  ///
  /// This stops the connection pool to clean up resources when the listener
  /// is no longer needed.
  ///
  /// Throws:
  /// - Propagates any exceptions from stopping connections.
  Future<void> disposeVdspListener() async {
    try {
      _logger.info('Disposing VDSP request listener', name: _logKey);
      await ConnectionPool.instance.stopConnections();
      _logger.info(
        'VDSP request listener disposed successfully',
        name: _logKey,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to dispose VDSP request listener',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // _handleAppResumed();
    }
  }

  /// Register the device token with the MeetingPlaceCoreSDK.
  ///
  /// Persists the [token] in the SDK for push notifications and marks the
  /// service as ready to process control plane events. Triggers an immediate
  /// processing of queued events after registration.
  ///
  /// [token] - The device token obtained from the push provider.
  ///
  /// Throws:
  /// Returns:
  /// - `Future<void>` completes when registration and subsequent processing
  ///  finish.
  /*
  Future<void> _registerDeviceToken(String token) async {
    _logger.info('Device token received: $token', name: _logKey);

    try {
      final sdk = await ref.read(mpxSdkProvider.future);
      _logger.info(
        'Registering device with MeetingPlaceCoreSDK',
        name: _logKey,
      );
      await sdk.registerForPushNotifications(token);
      _logger.info('Device registration completed successfully', name: _logKey);
      _tokenReceived = true;
      await _processEvents();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to register device token',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }
  */

  /*
  void _handleControlPlaneEvent(ControlPlaneStreamEvent event) {
    final channel = event.channel;
    _logger.info(
      'Handling event of type ${event.type.name} - '
      'channel status: ${channel.status} - '
      'permanentChannelDid: ${channel.permanentChannelDid} - '
      'otherPartyPermanentChannelDid: '
      '${channel.otherPartyPermanentChannelDid}',
      name: _logKey,
    );
  }
  */

  /*
  /// Handle app resume: clear badges and optionally process control plane
  /// events.
  ///
  /// On resume, if there are pending badges, the badge is cleared and the
  /// control plane events processor is invoked to handle any queued events.
  ///
  /// Returns:
  /// - `Future<void>` completes when badge clear and event processing (if any)
  ///  finish.
  ///
  /// Throws:
  /// - Propagates exceptions from app badge service or event processing.
  Future<void> _handleAppResumed() async {
    await ref.read(appBadgeServiceProvider).clearBadge();
    await _processEvents();
  }

  /// Trigger processing of control plane events if the service is ready.
  ///
  /// Will no-op if a device token has not been registered yet.
  ///
  /// Returns:
  /// - `Future<void>` completes when (if) processing has been triggered.
  ///
  /// Throws:
  /// - Propagates any exceptions thrown during processing initiation.
  Future<void> _processEvents() async {
    if (!_tokenReceived) return;

    if (_sdk == null) {
      _logger.error(
        '''Trying to process control plane events but MeetingPlaceCoreSDK is not yet initialized''',
        name: _logKey,
      );
      return;
    }
  }
  */
}
