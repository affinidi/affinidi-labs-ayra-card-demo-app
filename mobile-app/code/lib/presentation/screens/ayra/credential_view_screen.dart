import 'package:flutter/material.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/repositories/organizations_repository/organizations.dart';

class CredentialViewScreen extends StatelessWidget {
  const CredentialViewScreen({super.key, required this.credential});

  final ParsedVerifiableCredential credential;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vcTypes = credential.type.toList();
    final credentialTypeName = _formatTypeLabel(vcTypes.last);
    final issuerDid = credential.issuer.id.toString();
    final issuerText = Organizations.orgs
        .firstWhere(
          (p) => p.did == issuerDid,
          orElse: () => (did: issuerDid, name: issuerDid, website: ''),
        )
        .name;

    final credentialSubject = credential.credentialSubject.isNotEmpty
        ? credential.credentialSubject[0].toJson()
        : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credential Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with credential type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'CREDENTIAL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      credentialTypeName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_outlined,
                          size: 18,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Issued by $issuerText',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Validity section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Valid From',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(credential.validFrom),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Valid Until',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(credential.validUntil),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Credential subject data
                    Text(
                      'Credential Data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...credentialSubject.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCredentialField(
                          context,
                          entry.key,
                          entry.value,
                          theme,
                          colorScheme,
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Issuer details
                    Text(
                      'Issuer Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.business_outlined,
                      label: 'Organization',
                      value: issuerText,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.fingerprint_outlined,
                      label: 'DID',
                      value: issuerDid,
                      colorScheme: colorScheme,
                      theme: theme,
                      isMonospace: true,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Technical details
                    Text(
                      'Technical Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.tag_outlined,
                      label: 'Credential ID',
                      value: credential.id.toString(),
                      colorScheme: colorScheme,
                      theme: theme,
                      isMonospace: true,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Types',
                      value: vcTypes.join(', '),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialField(
    BuildContext context,
    String key,
    dynamic value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Special label for id field
    final displayKey = key.toLowerCase() == 'id'
        ? "Holder's DID"
        : _formatFieldLabel(key);
    final displayValue = _formatFieldValue(value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayKey,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldLabel(String key) {
    final spaced = key
        .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (match) => ' ')
        .replaceAll(RegExp('[_-]+'), ' ')
        .trim();
    if (spaced.isEmpty) {
      return key;
    }
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) return 'Not specified';

    if (value is Map) {
      return value.entries
          .map((e) => '${_formatFieldLabel(e.key.toString())}: ${e.value}')
          .join('\n');
    }

    if (value is List) {
      if (value.isEmpty) return 'None';

      // Check if it's a list of maps/objects
      if (value.first is Map) {
        return value
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key + 1;
              final item = entry.value as Map;
              final itemStr = item.entries
                  .map(
                    (e) =>
                        '  ${_formatFieldLabel(e.key.toString())}: ${e.value}',
                  )
                  .join('\n');
              return '[$index]\n${_trimLongText(itemStr)}';
            })
            .join('\n\n');
      }

      // List of primitives (strings, numbers, etc.)
      return value.join(', ');
    }

    return value.toString();
  }

  String _trimLongText(String text) {
    const maxLength = 1000; // 300 chars from start + 300 chars from end
    const charsFromEachEnd = 300;

    if (text.length <= maxLength) {
      return text;
    }

    final start = text.substring(0, charsFromEachEnd);
    final end = text.substring(text.length - charsFromEachEnd);
    final omittedCount = text.length - (charsFromEachEnd * 2);

    return '$start\n...($omittedCount characters omitted)...\n$end';
  }

  String _formatTypeLabel(String type) {
    final spaced = type
        .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (match) => ' ')
        .replaceAll(RegExp('[_-]+'), ' ')
        .trim();
    if (spaced.isEmpty) {
      return '';
    }
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.theme,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
