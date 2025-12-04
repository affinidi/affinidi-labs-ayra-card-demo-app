import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/services/vdip_service/vdip_service.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../widgets/ayra/ayra_button.dart';

enum _IdvScreenState { provider, inProgress, success }

class IdvFlowScreen extends ConsumerStatefulWidget {
  const IdvFlowScreen({super.key, this.autoStart = false});

  final bool autoStart;
  @override
  ConsumerState<IdvFlowScreen> createState() => _IdvFlowScreenState();
}

class _IdvFlowScreenState extends ConsumerState<IdvFlowScreen> {
  _IdvScreenState _screenState = _IdvScreenState.provider;
  String? _statusMessage;
  bool _isProcessing = false;

  Future<void> _initiateFlow() async {
    try {
      setState(() {
        _statusMessage = 'Initializing identity verification...';
        _isProcessing = true;
        _screenState = _IdvScreenState.inProgress;
      });
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final email = prefs.getString(SharedPreferencesKeys.email.name) ?? '';

      final vdipService = ref.read(vdipServiceProvider);

      final credentialsRequest = RequestCredentialsOptions(
        proposalId: CredentialHelper.verifiedIdentityDocument,
        credentialMeta: CredentialMeta(data: {'email': email}),
      );

      await vdipService.requestCredential(
        credentialsRequest: credentialsRequest,
        onProgress: (msg) async {
          if (mounted) {
            setState(() {
              _statusMessage = msg;
            });
          }
        },
        onComplete: (result) async {
          if (!mounted) return;

          if (result.isSuccess) {
            setState(() {
              _statusMessage =
                  'Identity verification credentials received successfully!';
              _isProcessing = false;
            });

            // Wait for credential to be fully saved
            await Future<void>.delayed(const Duration(milliseconds: 300));

            if (!mounted) return;

            // Show success message only on success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verified Identity Credentials issued successfully!',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            if (!mounted) return;

            // Navigate to success screen
            setState(() {
              _screenState = _IdvScreenState.success;
            });

            // Pop back to dashboard and indicate credential was issued
            Navigator.of(context).pop(true);
          } else if (result.isFailure) {
            setState(() {
              _statusMessage =
                  'Failed to receive credentials: ${result.message}';
              _isProcessing = false;
              _screenState =
                  _IdvScreenState.provider; // Go back to provider screen
            });
          } else if (result.isCancelled) {
            setState(() {
              _statusMessage = 'Identity verification was cancelled';
              _isProcessing = false;
              _screenState =
                  _IdvScreenState.provider; // Go back to provider screen
            });
          }
        },
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is AppException ? error.message : error.toString();

      setState(() {
        _statusMessage = 'Error: $message';
        _isProcessing = false;
        _screenState = _IdvScreenState.provider; // Go back to provider screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: switch (_screenState) {
        _IdvScreenState.provider => _buildProviderScreen(context),
        _IdvScreenState.inProgress => _buildProviderScreen(
          context,
        ), // Keep same screen
        _IdvScreenState.success => const _IdvSuccessContent(),
      },
    );
  }

  Widget _buildProviderScreen(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main heading
                  Text(
                    'Complete Your Identity Verification',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subheading
                  Text(
                    'Finish your onboarding process',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Info container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'What you\'ll need to do:',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStepItem(
                          context,
                          '1. Upload your ID document',
                          'Passport or driving license',
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          context,
                          '2. Take a selfie',
                          'For identity verification',
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          context,
                          '3. Get verified',
                          'Receive your reusable verified identity document',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You will be redirected to our trusted third-party provider for secure identity verification.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status message container (enhanced style from business card)
                  const SizedBox(height: 16),
                  if (_statusMessage != null && _statusMessage!.isNotEmpty) ...[
                    _buildStatusMessage(context),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Fixed button container at bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Button with loading state
                SizedBox(
                  width: double.infinity,
                  child: _isProcessing
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Verifying Identity...',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : AyraButton(
                          onPressed: _initiateFlow,
                          child: const Text('Start Identity Verification'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String title, String subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(BuildContext context) {
    final theme = Theme.of(context);
    final isError =
        _statusMessage?.startsWith('Error:') == true ||
        _statusMessage?.startsWith('Failed') == true ||
        _statusMessage?.contains('cancelled') == true;

    final colorScheme = theme.colorScheme;
    final backgroundColor = isError
        ? colorScheme.error.withValues(alpha: 0.15)
        : colorScheme.primary.withValues(alpha: 0.15);
    final borderColor = isError
        ? colorScheme.error.withValues(alpha: 0.4)
        : colorScheme.primary.withValues(alpha: 0.4);
    final iconColor = isError ? colorScheme.error : colorScheme.primary;
    final icon = isError ? Icons.error_outline : Icons.info_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdvSuccessContent extends ConsumerWidget {
  const _IdvSuccessContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi,', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Congrats, Your onboarding process is successfully completed. Below is your IDV Crendetails',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'You can claim your Ayra Business card by clicking on button below.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => const BusinessCardRoute().go(context),
              child: const Text('Get Ayra Business Card'),
            ),
          ),
        ],
      ),
    );
  }
}
