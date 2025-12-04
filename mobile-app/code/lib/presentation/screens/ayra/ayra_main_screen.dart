import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/vault_service/vault_service.dart';
import '../../../infrastructure/repositories/organizations_repository/organizations.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import 'ayra_credentials_screen.dart';
import 'ayra_dashboard_screen.dart';
import 'ayra_onboarding.dart';
import 'ayra_profile_screen.dart';
import 'ayra_scan_share_screen.dart';

class AyraMainScreen extends ConsumerStatefulWidget {
  const AyraMainScreen({super.key});

  @override
  ConsumerState<AyraMainScreen> createState() => _AyraMainScreenState();
}

class _AyraMainScreenState extends ConsumerState<AyraMainScreen> {
  int _selectedIndex = 0;
  bool _isSettingUp = false;
  bool _profileReady = false;
  String? _setupError;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AyraDashboardScreen(),
      const AyraCredentialsScreen(),
      const AyraProfileScreen(),
      const AyraScanShareScreen(),
      const SizedBox.shrink(),
    ];
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    if (_isSettingUp) return;
    setState(() {
      _isSettingUp = true;
      _setupError = null;
      _profileReady = false;
    });

    try {
      await ref.read(vaultServiceProvider.notifier).getProfile();
      if (!mounted) return;

      setState(() {
        _profileReady = true;
        _isSettingUp = false;
      });

      final organizations = Organizations.orgs.map((e) => e.name).toList();
      // Initialize default organization and check for existing sessions
      final onboardingNotifier = ref.read(ayraOnboardingProvider.notifier);

      // Below changeOrganization checks the issuer channel, user logged in etc..
      // gets the updated state if login is complete
      final prevState = ref.read(ayraOnboardingProvider);
      final onboardingState = await onboardingNotifier.changeOrganization(
        prevState.selectedOrganization ?? organizations.first,
      );
      debugLog('onboardingState.step: ${onboardingState.step}');

      if (onboardingState.step == AyraOnboardingStep.setupProfile) {
        onboardingNotifier.setStep(AyraOnboardingStep.login);
      }
    } catch (e, stackTrace) {
      debugLog('Profile setup failed: $e', error: e, stackTrace: stackTrace);
      if (!mounted) return;

      setState(() {
        _isSettingUp = false;
        _profileReady = false;
        _setupError = 'Unable to prepare your profile. Please retry.';
      });
    }
  }

  void _continueAfterSetup() {
    if (!_profileReady) {
      return;
    }
    ref.read(ayraOnboardingProvider.notifier).setStep(AyraOnboardingStep.login);
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(ayraOnboardingProvider);
    final step = onboardingState.step;

    if (step != AyraOnboardingStep.done) {
      return AyraOnboardingScreen(
        isSettingUp: _isSettingUp,
        profileReady: _profileReady,
        setupError: _setupError,
        onRetry: _initializeProfile,
        onContinue: _continueAfterSetup,
      );
    }

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/bb-logo-light.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          _selectedIndex == 0
              ? 'Dashboard'
              : _selectedIndex == 1
              ? 'Credentials'
              : _selectedIndex == 2
              ? 'Profile'
              : 'Scan & Share',
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_rounded),
            label: 'Credentials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profiles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Scan & Share',
          ),
        ],
      ),
    );
  }
}
