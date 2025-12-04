import 'package:flutter/material.dart';

class SetupProfileCard extends StatefulWidget {
  const SetupProfileCard({
    super.key,
    required this.isLoading,
    required this.isReady,
    required this.errorMessage,
    required this.onContinue,
    required this.onRetry,
  });

  final bool isLoading;
  final bool isReady;
  final String? errorMessage;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  @override
  State<SetupProfileCard> createState() => _SetupProfileCardState();
}

class _SetupProfileCardState extends State<SetupProfileCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Title
            Text(
              'Prepare Your Profile',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ensure your profile is ready before you begin. '
              'We keep credentials and DIDs synchronized across flows.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Status indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.isLoading
                  ? Container(
                      key: const ValueKey('loading'),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF4F39F6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Setting up your profile...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : widget.isReady
                  ? Container(
                      key: const ValueKey('ready'),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade300,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Profile Ready!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Ayra profile is ready. Continue to sign in with your organization.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade100,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Error Message
            if (widget.errorMessage != null &&
                widget.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_rounded,
                          color: Colors.red.shade300,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildRetryButton(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade300.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onRetry,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: widget.isLoading
                      ? Colors.red.shade300.withValues(alpha: 0.5)
                      : Colors.red.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isLoading
                        ? Colors.red.shade300.withValues(alpha: 0.5)
                        : Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
