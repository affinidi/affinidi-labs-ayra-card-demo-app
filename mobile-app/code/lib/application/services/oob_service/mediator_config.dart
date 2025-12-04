import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings_service/settings_service.dart';

class AppMediatorConfig {
  AppMediatorConfig({
    required this.mediatorDid,
    required this.mediatorEndpoint,
    required this.mediatorWSSEndpoint,
  });

  final String mediatorDid;
  final String mediatorEndpoint;
  final String mediatorWSSEndpoint;
}

AppMediatorConfig getCurrentMediatorConfig(Ref ref) {
  final settingsState = ref.read(settingsServiceProvider);
  final mediatorDid = settingsState.selectedMediatorDid;

  // Extract endpoint from mediator DID
  // Format: did:web:internal-atn-mediator.dev.euw1.affinidi.io:.well-known
  final parts = mediatorDid.split(':');
  final host = parts[2];

  return AppMediatorConfig(
    mediatorDid: mediatorDid,
    mediatorEndpoint: 'https://$host/mediator/v1',
    mediatorWSSEndpoint: 'wss://$host/mediator/v1',
  );
}
