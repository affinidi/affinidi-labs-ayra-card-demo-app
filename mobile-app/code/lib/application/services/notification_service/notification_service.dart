import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_service_state.dart';

part 'notification_service.g.dart';

/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.
@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  NotificationService() : super();

  @override
  NotificationServiceState build() {
    return NotificationServiceState();
  }
}
