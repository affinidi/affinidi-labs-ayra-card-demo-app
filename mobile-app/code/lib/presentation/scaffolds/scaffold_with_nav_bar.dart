import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/tabs/navigation_tab_destination.dart';
import '../../navigation/tabs/tabs.dart';
import '../screens/ayra/ayra_onboarding.dart';
import '../widgets/loaders/control_plane_events_progress_indicator.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final onboardingState = ref.watch(ayraOnboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ControlPlaneEventsProgressIndicator(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      // Only show navigation bar when onboarding is complete
      bottomNavigationBar: onboardingState.step == AyraOnboardingStep.done
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: Tabs.values
                  .map((tab) => tab.destination(l10n))
                  .toList(),
            )
          : null,
    );
  }
}
