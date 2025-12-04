import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/color_extensions.dart';
import 'authentication_screen_controller.dart';

class AuthenticationScreen extends HookConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final provider = authenticationScreenControllerProvider(
      l10n.authUnlockReason,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    String platformInstruction(BuildContext context) {
      final platform = Theme.of(context).platform;
      switch (platform) {
        case TargetPlatform.android:
          return l10n.authInstructionAndroid;
        case TargetPlatform.iOS:
          return l10n.authInstructionIos;
        case TargetPlatform.macOS:
          return l10n.authInstructionMacos;
        default:
          return ''; // no hint for web, desktop, etc.
      }
    }

    useEffect(() {
      Future.microtask(() async {
        // Preload splash image to avoid flicker
        await precacheImage(
          const AssetImage('assets/images/bb-logo-colorl-light.png'),
          context,
        );
        await controller.onAppResumed(l10n.authUnlockReason);
      });

      return null;
    }, []);

    // AL: Calculate width to constrain for large screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth > 1024 ? 6.0 : 2.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: radius,
            colors: [
              colorScheme.primary.withLightness(0.3),
              colorScheme.primary.withAlpha(249),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/images/bb-logo-colorl-light.png',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(l10n.appName, style: textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        if (!state.isLoading && state.isError) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Text(
                                  state.error ?? l10n.toProtectData,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  platformInstruction(context),
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () =>
                                controller.retry(l10n.authUnlockReason),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.generalRetry,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/affinidi_labs_icon.png',
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-12, -4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.poweredBy, style: textTheme.bodySmall),
                        Text(l10n.messagingEngine, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
