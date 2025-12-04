import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/authentication_service/authentication_service.dart';
import 'authentication_screen_state.dart';

part 'authentication_screen_controller.g.dart';

@riverpod
class AuthenticationScreenController extends _$AuthenticationScreenController {
  @override
  AuthenticationScreenState build(String unlockReason) {
    // Listen for authentication service errors (optional)
    ref.listen(authenticationServiceProvider, (previous, next) {
      if (previous != null && !next.isAuthenticated && !next.isLoading) {
        Future(() {
          state = state.copyWith(isError: true);
        });
      }
    }, fireImmediately: true);

    // Attach lifecycle listener once
    final lifecycleListener = AppLifecycleListener(
      onResume: () => onAppResumed(unlockReason),
      onInactive: () async {
        await Future(() {
          state = state.copyWith(isAppResumed: false, isLoading: false);
        });
      },
    );
    ref.onDispose(lifecycleListener.dispose);

    return const AuthenticationScreenState();
  }

  Future<void> onAppResumed(String unlockReason) async {
    if (state.isLoading || state.hasAttemptedAuth) return;
    await Future(() {
      state = state.copyWith(isLoading: true, isAppResumed: true);
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500), () async {
        if (!state.isAppResumed) {
          await Future(() {
            state = state.copyWith(isLoading: false);
          });
          return;
        }
        await _authenticate(unlockReason);
        await Future(() {
          state = state.copyWith(hasAttemptedAuth: true);
        });
      });
    } catch (e) {
      await Future(() {
        state = state.copyWith(isError: true, error: e.toString());
      });
    } finally {
      await Future(() {
        state = state.copyWith(isLoading: false);
      });
    }
  }

  Future<void> retry(String unlockReason) async {
    state = state.copyWith(isLoading: false);
    await _authenticate(unlockReason);
  }

  Future<void> _authenticate(String unlockReason) async {
    final authService = ref.read(authenticationServiceProvider.notifier);
    await authService.authenticate(unlockReason);
  }
}
