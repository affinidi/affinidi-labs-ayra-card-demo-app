import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/services/control_plane_service/control_plane_service.dart';
import '../../application/services/network_connectivity_service/network_connectivity_service.dart';
import '../../application/services/vault_service/vault_service.dart';
import '../../infrastructure/providers/app_badge_provider.dart';

part 'app_controller.g.dart';

@Riverpod(keepAlive: true)
class AppController extends _$AppController {
  AppController() : super();

  @override
  void build() {
    Future(() async {
      //ref.read(settingsServiceProvider);
      ref.read(controlPlaneServiceProvider);
      // ref.read(identitiesServiceProvider);
      ref.read(networkConnectivityServiceProvider);
      ref.read(vaultServiceProvider);
      unawaited(ref.read(appBadgeServiceProvider).clearBadge());
    });
  }
}
