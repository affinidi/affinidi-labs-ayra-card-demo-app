import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/login_service/login_service.dart';
import '../../../application/services/login_service/login_service_state.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/repositories/organizations_repository/organizations.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import 'components/components.dart';

enum AyraOnboardingStep { setupProfile, login, done }

const _logKey = 'AyraOnboarding';

class AyraOnboardingState {
  AyraOnboardingState({
    this.step = AyraOnboardingStep.setupProfile,
    this.selectedOrganization,
  });

  final AyraOnboardingStep step;
  final String? selectedOrganization;

  AyraOnboardingState copyWith({
    AyraOnboardingStep? step,
    String? selectedOrganization,
  }) {
    return AyraOnboardingState(
      step: step ?? this.step,
      selectedOrganization: selectedOrganization ?? this.selectedOrganization,
    );
  }
}

class AyraOnboardingNotifier extends StateNotifier<AyraOnboardingState> {
  AyraOnboardingNotifier(this._ref) : super(AyraOnboardingState());

  final Ref _ref;
  late final logger = _ref.read(appLoggerProvider);

  void setStep(AyraOnboardingStep step) {
    state = state.copyWith(step: step);
  }

  void reset() {
    state = AyraOnboardingState();
  }

  void rememberOrganization(String organization) {
    state = state.copyWith(selectedOrganization: organization);
  }

  void goBack() {
    if (state.step == AyraOnboardingStep.login) {
      state = state.copyWith(step: AyraOnboardingStep.setupProfile);
    }
  }

  void completeOnboarding() {
    setStep(AyraOnboardingStep.done);
  }

  /// Initializes the onboarding by checking for existing channels
  Future<void> initializeOnboarding() async {
    final resumed = await resumeIfChannelExists();
    if (!resumed) {
      // Start with setup profile if no existing channel
      setStep(AyraOnboardingStep.setupProfile);
    }
  }

  /// Handles organization change and checks for existing channels
  Future<AyraOnboardingState> changeOrganization(String organization) async {
    rememberOrganization(organization);

    // Check if we can resume with existing channel
    final resumed = await resumeIfChannelExists();
    if (!resumed) {
      setStep(AyraOnboardingStep.login);
    }

    return state;
  }

  /// Completes the onboarding process with login
  Future<void> completeOnboardingWithLogin(
    String email,
    String organization,
  ) async {
    try {
      rememberOrganization(organization);
      final loginNotifier = _ref.read(loginServiceProvider.notifier);
      await loginNotifier.login(email: email, provider: organization);
      completeOnboarding();
    } catch (e, stackTrace) {
      debugLog(
        'Login failed for $email ($organization)',
        name: _logKey,
        logger: logger,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Let the UI handle the error display
    }
  }

  /// Checks if there's an existing channel and resumes if possible
  Future<bool> resumeIfChannelExists() async {
    try {
      debugLog(
        'Attempting to check state of user...',
        name: _logKey,
        logger: logger,
      );
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final cachedIssuerDid = prefs.getString(
        SharedPreferencesKeys.issuerDidCache.name,
      );

      debugLog(
        'alreadyOnboarded : ${prefs.getBool(SharedPreferencesKeys.alreadyOnboarded.name)}',
        name: _logKey,
        logger: logger,
      );
      debugLog(
        'cachedIssuerDid : $cachedIssuerDid',
        name: _logKey,
        logger: logger,
      );
      debugLog(
        'displayName : ${prefs.getString(SharedPreferencesKeys.displayName.name)}',
        name: _logKey,
        logger: logger,
      );
      debugLog(
        'provider : ${prefs.getString(SharedPreferencesKeys.provider.name)}',
        name: _logKey,
        logger: logger,
      );
      if (cachedIssuerDid == null || cachedIssuerDid.isEmpty) {
        return false;
      }

      final sdk = await _ref.read(mpxSdkProvider.future);
      final existingChannel = await sdk.getChannelByOtherPartyPermanentDid(
        cachedIssuerDid,
      );

      if (existingChannel != null) {
        completeOnboarding();
        return true;
      }

      return false;
    } catch (error) {
      debugLog(
        'Unable to resume onboarding using cached DID',
        name: _logKey,
        logger: logger,
        error: error,
      );
      return false;
    }
  }
}

final ayraOnboardingProvider =
    StateNotifierProvider<AyraOnboardingNotifier, AyraOnboardingState>(
      AyraOnboardingNotifier.new,
    );

class AyraOnboardingScreen extends ConsumerStatefulWidget {
  const AyraOnboardingScreen({
    super.key,
    required this.isSettingUp,
    required this.profileReady,
    required this.onContinue,
    required this.onRetry,
    this.setupError,
  });

  final bool isSettingUp;
  final bool profileReady;
  final String? setupError;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  @override
  ConsumerState<AyraOnboardingScreen> createState() =>
      _AyraOnboardingScreenState();
}

class _AyraOnboardingScreenState extends ConsumerState<AyraOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation for logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check for existing channel on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingChannel();
    });
  }

  Future<void> _checkExistingChannel() async {
    final onboardingNotifier = ref.read(ayraOnboardingProvider.notifier);
    await onboardingNotifier.initializeOnboarding();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Read state from providers
    final onboardingState = ref.watch(ayraOnboardingProvider);
    final loginState = ref.watch(loginServiceProvider);
    final onboardingNotifier = ref.read(ayraOnboardingProvider.notifier);

    final step = onboardingState.step;
    final selectedOrganization = onboardingState.selectedOrganization;
    final organizations = Organizations.orgs.map((e) => e.name).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sweetlane Group',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Common animated logo at the top
          _buildAnimatedLogo(),

          // Step-specific content
          Expanded(
            child: _buildStepCard(
              step: step,
              isSettingUp: widget.isSettingUp,
              profileReady: widget.profileReady,
              setupError: widget.setupError,
              organizations: organizations,
              selectedOrganization: selectedOrganization,
              onContinue: widget.onContinue,
              onRetry: widget.onRetry,
              loginState: loginState,
              onboardingNotifier: onboardingNotifier,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 3,
                ),
                boxShadow: [
                  // Purple glow
                  BoxShadow(
                    color: const Color(
                      0xFF4F39F6,
                    ).withValues(alpha: 0.6 * _pulseAnimation.value),
                    blurRadius: 30 * _pulseAnimation.value,
                    spreadRadius: 5 * _pulseAnimation.value,
                  ),
                  // Magenta glow
                  BoxShadow(
                    color: const Color(
                      0xFF9810FA,
                    ).withValues(alpha: 0.5 * _pulseAnimation.value),
                    blurRadius: 40 * _pulseAnimation.value,
                    spreadRadius: 3 * _pulseAnimation.value,
                  ),
                  // Pink glow
                  BoxShadow(
                    color: const Color(
                      0xFFE60076,
                    ).withValues(alpha: 0.4 * _pulseAnimation.value),
                    blurRadius: 50 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: ClipOval(child: _buildLogo()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.business_rounded, size: 60, color: Colors.white),
    );
  }

  Widget _buildStepCard({
    required AyraOnboardingStep step,
    required bool isSettingUp,
    required bool profileReady,
    required String? setupError,
    required List<String> organizations,
    required VoidCallback onContinue,
    required VoidCallback onRetry,
    required LoginServiceState loginState,
    required AyraOnboardingNotifier onboardingNotifier,
    String? selectedOrganization,
  }) {
    switch (step) {
      case AyraOnboardingStep.setupProfile:
        return SetupProfileCard(
          key: const ValueKey('setup'),
          isLoading: isSettingUp,
          isReady: profileReady,
          errorMessage: setupError,
          onContinue: onContinue,
          onRetry: onRetry,
        );
      case AyraOnboardingStep.login:
        return LoginCard(
          key: const ValueKey('login'),
          organizations: organizations,
          selectedOrganization: selectedOrganization,
          onOrganizationChanged: onboardingNotifier.changeOrganization,
          onLogin: onboardingNotifier.completeOnboardingWithLogin,
          isLoading: loginState.isLoading,
          errorMessage: loginState.errorMessage,
          statusMessage: loginState.statusMessage,
          step: loginState.step,
        );
      case AyraOnboardingStep.done:
        return const SizedBox.shrink();
    }
  }
}
