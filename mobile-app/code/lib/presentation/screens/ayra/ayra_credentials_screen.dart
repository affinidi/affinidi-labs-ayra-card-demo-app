import 'package:affinidi_tdk_vault/affinidi_tdk_vault.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';

import '../../../application/services/vault_service/vault_service.dart';
import '../../../application/services/vault_service/vault_service_state.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../widgets/flip_card/flip_card_controller.dart';
import 'components/ayra_card.dart';
import 'components/generic_credential_card.dart';

class AyraCredentialsScreen extends ConsumerStatefulWidget {
  const AyraCredentialsScreen({super.key});

  @override
  ConsumerState<AyraCredentialsScreen> createState() =>
      _AyraCredentialsScreenState();
}

const _logKey = 'AYRA_CREDENTIALS';

class _AyraCredentialsScreenState extends ConsumerState<AyraCredentialsScreen> {
  bool _hasRequestedCredentials = false;
  bool _isInitialLoading = false;
  String? _loadError;
  late final _logger = ref.read(appLoggerProvider);
  ProviderSubscription<VaultServiceState>? _vaultSubscription;
  final Set<String> _deletingCredentialIds = <String>{};
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    // Reset all flip card states to show front side by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flipCardControllerProvider.notifier).flipBack();
    });

    _vaultSubscription = ref.listenManual<VaultServiceState>(
      vaultServiceProvider,
      (previous, next) => _handleVaultState(next),
    );
    _handleVaultState(ref.read(vaultServiceProvider));
  }

  @override
  void dispose() {
    _vaultSubscription?.close();
    super.dispose();
  }

  void _handleVaultState(VaultServiceState state) {
    if (_hasRequestedCredentials || state.vault == null) {
      return;
    }
    _logger.debug(
      'Vault instance available. Loading credentials…',
      name: _logKey,
    );
    _hasRequestedCredentials = true;
    _loadError = null;
    setState(() {
      _isInitialLoading = true;
    });
    _triggerLoad();
  }

  Future<void> _triggerLoad() async {
    _logger.info('Requesting credentials from vault', name: _logKey);
    try {
      await ref.read(vaultServiceProvider.notifier).getCredentials(force: true);
      final count =
          ref.read(vaultServiceProvider).claimedCredentials?.length ?? 0;
      _logger.info('Loaded $count credential(s) from vault', name: _logKey);
      if (!mounted) return;
      setState(() {
        _loadError = null;
        _isInitialLoading = false;
      });
    } catch (error, stackTrace) {
      debugLog(
        'Failed to load credentials',
        name: _logKey,
        logger: _logger,
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load credentials. Please try again.';
        _isInitialLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_loadError!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultServiceProvider);
    final credentials = vaultState.claimedCredentials;
    final entries = credentials == null
        ? const <_CredentialEntry>[]
        : credentials
              .map((DigitalCredential digitalCredential) {
                final verifiable =
                    digitalCredential.verifiableCredential
                        as ParsedVerifiableCredential;
                final digitalId = digitalCredential.id;
                return _CredentialEntry(
                  credential: verifiable,
                  digitalId: digitalId,
                );
              })
              .whereType<_CredentialEntry>()
              .toList();

    final isLoading = credentials == null || _isInitialLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credentials'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _triggerLoad,
          child: _buildCredentialContent(entries, isLoading),
        ),
      ),
    );
  }

  Widget _buildCredentialContent(
    List<_CredentialEntry> entries,
    bool isLoading,
  ) {
    if (isLoading) {
      return const _CredentialsLoading();
    } else if (entries.isEmpty) {
      return const _EmptyCredentials();
    } else {
      return _buildWalletStack(entries);
    }
  }

  Widget _buildWalletStack(List<_CredentialEntry> entries) {
    const stackedCardOffset = 60.0;
    const topPadding = 20.0;
    const cardHeight = 280.0; // Fixed height for all cards in stack

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isAnyExpanded = _expandedIndex != null;

        // Calculate total stack height to make it scrollable
        final totalStackHeight = isAnyExpanded
            ? screenHeight
            : topPadding +
                  (entries.length * stackedCardOffset) +
                  cardHeight +
                  100;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: totalStackHeight > screenHeight
                ? totalStackHeight
                : screenHeight,
            child: Stack(
              children: [
                // All cards with animation
                ...List.generate(entries.length, (index) {
                  final isThisExpanded = _expandedIndex == index;
                  final isAnyExpanded = _expandedIndex != null;

                  // Calculate position
                  double top;
                  if (isAnyExpanded) {
                    if (isThisExpanded) {
                      // This card is expanded - stay at top
                      top = topPadding;
                    } else {
                      // Other cards - move down and off screen
                      top = screenHeight + 100;
                    }
                  } else {
                    // Normal stacked position
                    top = topPadding + (index * stackedCardOffset);
                  }

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    top: top,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      // Swipe down gesture on expanded card to collapse
                      onVerticalDragEnd: isThisExpanded
                          ? (details) {
                              if (details.primaryVelocity != null &&
                                  details.primaryVelocity! > 300) {
                                _collapseCard();
                              }
                            }
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Constrain card height when in stacked view
                          Container(
                            height: isThisExpanded ? null : cardHeight,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  // Render appropriate card based on credential type
                                  _buildCredentialCard(
                                    entries[index],
                                    isThisExpanded,
                                  ),

                                  // Overlay to capture taps when not expanded
                                  if (!isThisExpanded && !isAnyExpanded)
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () => _expandCard(index),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Show additional details when expanded
                          if (isThisExpanded)
                            _buildCredentialDetails(
                              entries[index].credential,
                              entries[index].digitalId,
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                // "Show All Cards" button at bottom when expanded
                if (_expandedIndex != null)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _collapseCard,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.layers, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Show All Credentials',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCredentialCard(_CredentialEntry entry, bool isExpanded) {
    final credential = entry.credential;
    // Check if this is an Ayra Business Card (should use AyraCard)
    if (credential.type.contains(CredentialHelper.ayraBusinessCard)) {
      return AyraCard.fromCredential(
        credential: credential,
        isVerified: true,
        isClaimed: true,
        // Allow flip only when not expanded (to avoid conflicts)
        // The AyraCard will handle its own flip logic internally
      );
    } else {
      // For all other credential types, use GenericCredentialCard
      return GenericCredentialCard(
        credential: credential,
        // Allow flip only when not expanded (to avoid conflicts)
      );
    }
  }

  Future<void> _deleteCredential(String? credentialId) async {
    if (credentialId == null || credentialId.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credential identifier missing. Cannot delete.'),
          ),
        );
      }
      return;
    }
    if (_deletingCredentialIds.contains(credentialId)) {
      return;
    }

    setState(() {
      _deletingCredentialIds.add(credentialId);
    });

    try {
      await ref
          .read(vaultServiceProvider.notifier)
          .deleteCredential(credentialId);
      _logger.info('Deleted credential $credentialId', name: _logKey);

      // Collapse the expanded view to show all credentials
      if (mounted) {
        setState(() {
          _expandedIndex = null;
        });
      }

      await _triggerLoad();
      if (!mounted) return;
      if (_loadError == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Credential deleted.')));
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to delete credential $credentialId',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete credential. Please try again.'),
          ),
        );
      }
    } finally {
      if (!mounted) {
        _deletingCredentialIds.remove(credentialId);
      } else {
        setState(() {
          _deletingCredentialIds.remove(credentialId);
        });
      }
    }
  }

  Widget _buildCredentialDetails(
    ParsedVerifiableCredential credential,
    String? digitalId,
  ) {
    final details = _extractCredentialDetails(credential);
    if (details.isEmpty) return const SizedBox.shrink();

    final isDeleting =
        digitalId != null && _deletingCredentialIds.contains(digitalId);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 100),
        constraints: const BoxConstraints(
          maxHeight: 400, // Limit height to make it scrollable
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Credential Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button only for Ayra Business Card
                      if (credential.type.contains(
                        CredentialHelper.ayraBusinessCard,
                      ))
                        IconButton(
                          onPressed: _editAyraCard,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          tooltip: 'Edit Credential',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (credential.type.contains(
                        CredentialHelper.ayraBusinessCard,
                      ))
                        const SizedBox(width: 16),
                      IconButton(
                        onPressed: isDeleting
                            ? null
                            : () => _showDeleteConfirmation(digitalId),
                        icon: isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                        tooltip: 'Delete credential',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        detail['icon'] as IconData,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail['label'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detail['value'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String? credentialId) async {
    if (credentialId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Credential'),
          content: const Text(
            'Are you sure you want to delete this credential? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteCredential(credentialId);
    }
  }

  List<Map<String, dynamic>> _extractCredentialDetails(
    ParsedVerifiableCredential credential,
  ) {
    final details = <Map<String, dynamic>>[];

    try {
      // Common credential information (defined in main screen)
      details.add({
        'icon': Icons.fingerprint,
        'label': 'Credential ID',
        'value': credential.id.toString(),
      });

      details.add({
        'icon': Icons.business,
        'label': 'Issued by',
        'value': credential.issuer.id.toString(),
      });

      // Issuance date
      if (credential.validFrom != null) {
        try {
          final date = credential.validFrom!;
          details.add({
            'icon': Icons.calendar_today,
            'label': 'Issued on',
            'value': '${date.day}/${date.month}/${date.year}',
          });
        } catch (e) {
          // Handle date parsing error
        }
      }

      // Expiration date
      if (credential.validUntil != null) {
        try {
          final date = credential.validUntil!;
          details.add({
            'icon': Icons.event_available,
            'label': 'Expires on',
            'value': '${date.day}/${date.month}/${date.year}',
          });
        } catch (e) {
          // Handle date parsing error
        }
      }

      // details.add({
      //   'icon': Icons.check_circle,
      //   'label': 'Status',
      //   'value': 'Active',
      // });

      details.add({
        'icon': Icons.fingerprint,
        'label': 'Subject ID',
        'value': credential.credentialSubject[0]['id'].toString(),
      });

      // Delegate credential-specific details to the appropriate card component
      // and add them all to the details list
      if (credential.type.contains(CredentialHelper.ayraBusinessCard)) {
        details.addAll(AyraCard.extractCredentialDetails(credential));
      } else {
        details.addAll(
          GenericCredentialCard.extractCredentialDetails(credential),
        );
      }
    } catch (e) {
      _logger.error('Error extracting credential details: $e', name: _logKey);
    }

    return details;
  }

  void _expandCard(int index) {
    setState(() {
      _expandedIndex = index;
    });
  }

  void _collapseCard() {
    // Flip the card back to front before collapsing
    ref.read(flipCardControllerProvider.notifier).flipBack();

    setState(() {
      _expandedIndex = null;
    });
  }

  void _editAyraCard() {
    // Collapse the expanded view
    setState(() {
      _expandedIndex = null;
    });

    // Navigate to business card screen for editing
    const BusinessCardRoute().push<void>(context);
  }
}

class _CredentialEntry {
  const _CredentialEntry({required this.credential, this.digitalId});

  final ParsedVerifiableCredential credential;
  final String? digitalId;
}

class _CredentialsLoading extends StatelessWidget {
  const _CredentialsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Fetching credentials from your vault...'),
          ],
        ),
      ),
    );
  }
}

class _EmptyCredentials extends StatelessWidget {
  const _EmptyCredentials();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No credentials found',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Once you accept credentials, '
              'they will appear here ready to be presented.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
