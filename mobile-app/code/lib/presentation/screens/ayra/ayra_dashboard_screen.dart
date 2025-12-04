import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/vault_service/vault_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../widgets/ayra/ayra_button.dart';
import 'components/ayra_card.dart';
import 'components/ayra_profile_card.dart';

class AyraDashboardScreen extends ConsumerStatefulWidget {
  const AyraDashboardScreen({super.key});

  @override
  ConsumerState<AyraDashboardScreen> createState() =>
      _AyraDashboardScreenState();
}

class _AyraDashboardScreenState extends ConsumerState<AyraDashboardScreen>
    with WidgetsBindingObserver {
  static const _logKey = 'Dashboard';
  late final _logger = ref.read(appLoggerProvider);
  String? _userEmail;
  bool _isInitialized = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugLog(
        'Dashboard: App resumed, refreshing credentials...',
        name: _logKey,
        logger: _logger,
      );
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      debugLog(
        'Dashboard: Loading dashboard data...',
        name: _logKey,
        logger: _logger,
      );
      // Force load credentials to ensure fresh data
      await ref.read(vaultServiceProvider.notifier).getCredentials(force: true);

      // Load email from SharedPreferences
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final email = prefs.getString(SharedPreferencesKeys.email.name);

      if (mounted) {
        setState(() {
          _userEmail = email;
          _isInitialized = true;
        });
      }
      debugLog(
        'Dashboard: Data loaded successfully',
        name: _logKey,
        logger: _logger,
      );
    } catch (e) {
      debugLog(
        'Dashboard: Error loading dashboard data',
        name: _logKey,
        logger: _logger,
        error: e,
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Use ref.watch to rebuild when credentials change
    final vaultState = ref.watch(vaultServiceProvider);
    final digitalCredentials = vaultState.claimedCredentials ?? [];

    debugLog(
      'Dashboard: vaultState has ${digitalCredentials.length} credentials',
      name: _logKey,
      logger: _logger,
    );

    // Loading state: show loading until initialized AND credentials are loaded
    final isLoading = !_isInitialized || vaultState.claimedCredentials == null;

    final employmentCard = digitalCredentials.where((credential) {
      return credential.verifiableCredential.type.contains(
        CredentialHelper.employment,
      );
    }).firstOrNull;

    final idvCard = digitalCredentials.where((credential) {
      return credential.verifiableCredential.type.contains(
        CredentialHelper.verifiedIdentityDocument,
      );
    }).firstOrNull;

    final ayraCard = digitalCredentials.where((credential) {
      return credential.verifiableCredential.type.contains(
        CredentialHelper.ayraBusinessCard,
      );
    }).firstOrNull;

    // Determine verification and claimed status based on credentials
    final isVerified =
        idvCard != null; // Hardcoded to true for now - idvCard != null;
    final isClaimed = ayraCard != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Please wait...'),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show employment credential if available
                      if (employmentCard != null) ...[
                        ProfileCard.fromCredential(
                          credential: employmentCard.verifiableCredential,
                          email: _userEmail,
                        ),
                        const SizedBox(height: 24),

                        // Show Ayra Business Card (always show, let the card handle display based on isClaimed)
                        AyraCard.fromCredential(
                          credential: isClaimed
                              ? ayraCard.verifiableCredential
                              : employmentCard.verifiableCredential,
                          isVerified: isVerified,
                          isClaimed: isClaimed,
                          onClaim: () async {
                            debugLog(
                              'Dashboard: Navigating to business card claim...',
                              name: _logKey,
                              logger: _logger,
                            );
                            // Navigate to business card claim flow
                            final result = await const BusinessCardRoute()
                                .push<bool>(context);
                            debugLog(
                              'Dashboard: Returned from business card, result=$result',
                              name: _logKey,
                              logger: _logger,
                            );
                            // If credential was issued, refresh
                            if (result == true && mounted) {
                              setState(() => _isRefreshing = true);
                              debugLog(
                                'Dashboard: Credential was issued, refreshing...',
                                name: _logKey,
                                logger: _logger,
                              );
                              await _loadDashboardData();
                              if (mounted) {
                                setState(() => _isRefreshing = false);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Only show verification CTA if not verified
                      if (!isVerified) ...[
                        const SizedBox(height: 24),
                        AyraButton(
                          onPressed: () async {
                            debugLog(
                              'Dashboard: Navigating to IDV flow...',
                              name: _logKey,
                              logger: _logger,
                            );
                            final result = await const IdvFlowRoute()
                                .push<bool>(context);
                            debugLog(
                              'Dashboard: Returned from IDV flow, result=$result',
                              name: _logKey,
                              logger: _logger,
                            );
                            // If credential was issued, refresh
                            if (result == true && mounted) {
                              setState(() => _isRefreshing = true);
                              debugLog(
                                'Dashboard: IDV credential was issued, refreshing...',
                                name: _logKey,
                                logger: _logger,
                              );
                              await _loadDashboardData();
                              if (mounted) {
                                setState(() => _isRefreshing = false);
                              }
                            }
                          },
                          child: const Text('Complete Identity Verification'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Please prepare a valid passport or driver\'s license to verify your identity.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

          // Loading overlay when refreshing
          if (_isRefreshing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Updating credentials...',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
