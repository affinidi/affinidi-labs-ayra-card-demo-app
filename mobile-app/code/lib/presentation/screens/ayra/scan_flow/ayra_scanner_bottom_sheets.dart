import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssi/ssi.dart';

import '../../../../application/services/vdsp_service/vdsp_service.dart';
import '../components/generic_credential_card.dart';

// Biometric Authentication Bottom Sheet
class BiometricBottomSheet extends StatefulWidget {
  const BiometricBottomSheet({
    super.key,
    required this.onAuthenticated,
    required this.onCancel,
  });

  final VoidCallback onAuthenticated;
  final VoidCallback onCancel;

  @override
  State<BiometricBottomSheet> createState() => _BiometricBottomSheetState();
}

class _BiometricBottomSheetState extends State<BiometricBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _touchController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isTouched = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _touchController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _touchController, curve: Curves.easeInOut),
    );

    _slideController.forward();

    // Simulate biometric authentication with touch animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isTouched = true;
        });
        _touchController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              widget.onAuthenticated();
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _touchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isTouched ? 'Authenticated' : 'Authenticating',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade100,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Center(
                  child: AnimatedBuilder(
                    animation: _touchController,
                    builder: (context, child) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF4F39F6,
                            ).withValues(alpha: _glowAnimation.value),
                            boxShadow: _isTouched
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4F39F6,
                                      ).withValues(alpha: 0.6),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ]
                                : [],
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 60,
                            color: Color(0xFF4F39F6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isTouched ? 'Verified!' : 'Touch ID to verify',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isTouched
                        ? Colors.green.shade400
                        : Colors.grey.shade400,
                    fontWeight: _isTouched
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sharing Credential Bottom Sheet
class SharingBottomSheet extends StatefulWidget {
  const SharingBottomSheet({
    super.key,
    required this.onComplete,
    required this.onCancel,
  });

  final VoidCallback onComplete;
  final VoidCallback onCancel;

  @override
  State<SharingBottomSheet> createState() => _SharingBottomSheetState();
}

class _SharingBottomSheetState extends State<SharingBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Future<ParsedVerifiablePresentation>? _credentialFuture;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
    _credentialFuture = _loadEmployeeCredential();
    _startSharing();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<ParsedVerifiablePresentation> _loadEmployeeCredential() async {
    final jsonString = await rootBundle.loadString(
      'assets/employee-credentials.json',
    );
    return UniversalPresentationParser.parse(jsonString);
  }

  void _startSharing() {
    // Animate progress bar (10 seconds)
    const steps = 100;
    const stepDuration = Duration(milliseconds: 100);

    for (var i = 0; i <= steps; i++) {
      Future.delayed(stepDuration * i, () {
        if (mounted) {
          setState(() {
            _progress = i / steps;
          });

          if (i == steps) {
            // Sharing complete
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                widget.onComplete();
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sharing Credential',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade100,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Meeting Room A is requesting access to your:',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FutureBuilder<ParsedVerifiablePresentation>(
                  future: _credentialFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final credential = snapshot.data!;
                    return GenericCredentialCard(
                      credential: credential as VerifiableCredential,
                      canFlip: false,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Cancel button with progress fill
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Background fill that progresses from left to right
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              flex: (_progress * 100).toInt(),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade900,
                                      Colors.red.shade700,
                                      Colors.red.shade400,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 100 - (_progress * 100).toInt(),
                              child: Container(
                                color: Colors.red.shade900.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Button content
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onCancel,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Result Bottom Sheet (Success or Failure)
class ResultBottomSheet extends StatefulWidget {
  const ResultBottomSheet({
    super.key,
    required this.result,
    required this.onDone,
  });

  final VdspScanResult result;
  final VoidCallback onDone;

  @override
  State<ResultBottomSheet> createState() => _ResultBottomSheetState();
}

class _ResultBottomSheetState extends State<ResultBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;

  bool get _isSuccess => widget.result.isSuccess;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _iconController.forward();

    // Auto-close success after 3 seconds, failure requires manual dismiss
    if (_isSuccess) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onDone();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isSuccess ? Colors.green.shade500 : Colors.red.shade500;
    final icon = _isSuccess ? Icons.check : Icons.close;
    final title = _isSuccess ? 'Success!' : 'Failed';

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _iconScaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 60,
                      weight: 700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade100,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.result.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Show dismiss button only for failure
                if (!_isSuccess)
                  ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Share Confirmation Bottom Sheet
class ShareConfirmationBottomSheet extends StatefulWidget {
  const ShareConfirmationBottomSheet({
    super.key,
    required this.operation,
    required this.credentials,
    required this.onConfirm,
    required this.onCancel,
  });

  final String operation;
  final List<ParsedVerifiableCredential<dynamic>> credentials;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<ShareConfirmationBottomSheet> createState() =>
      _ShareConfirmationBottomSheetState();
}

class _ShareConfirmationBottomSheetState
    extends State<ShareConfirmationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Set<int> _selectedIndices = <int>{};
  int _topCardIndex = 0; // Track which card is on top

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
    // Pre-select all credentials by default
    _selectedIndices.addAll(
      List.generate(widget.credentials.length, (index) => index),
    );
    // Set the last card as the top card initially
    _topCardIndex = widget.credentials.length - 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.business, 'Purpose: ${widget.operation}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F39F6), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Credential Request',
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.grey.shade100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Your Credential${widget.credentials.length > 1 ? 's' : ''}',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display credentials in stack
                      if (widget.credentials.isNotEmpty)
                        _buildCredentialStack()
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'No credentials to share',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      // Hide credential count section
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade800.withValues(alpha:0.5),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: Colors.orange.shade700.withValues(alpha:0.3),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.info_outline,
                      //         color: Colors.orange.shade700,
                      //         size: 24,
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Expanded(
                      //         child: Text(
                      //           '${_selectedIndices.length} credential${_selectedIndices.length != 1 ? 's' : ''} selected to share',
                      //           style: TextStyle(
                      //             color: Colors.grey.shade300,
                      //             fontSize: 13,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _selectedIndices.isEmpty
                            ? null
                            : widget.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F39F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm & Share',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onCancel,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
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

  Widget _buildCredentialStack() {
    const stackedCardOffset = 60.0;
    const cardHeight = 260.0;

    final totalHeight =
        cardHeight + ((widget.credentials.length - 1) * stackedCardOffset);

    final renderOrder = List.generate(widget.credentials.length, (i) => i);
    if (_topCardIndex < renderOrder.length) {
      renderOrder.remove(_topCardIndex);
      renderOrder.add(_topCardIndex);
    }

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: renderOrder.map((i) {
          final isSelected = _selectedIndices.contains(i);
          final credential = widget.credentials[i];

          final positionIndex = i == _topCardIndex
              ? widget.credentials.length - 1
              : (i > _topCardIndex ? i - 1 : i);
          final topOffset = positionIndex * stackedCardOffset;

          return AnimatedPositioned(
            key: ValueKey(i),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: topOffset,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  // Move this card to the top
                  _topCardIndex = i;
                });
              },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: i == _topCardIndex ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      // Credential card with constrained height - wrapped to block taps
                      Positioned.fill(
                        child: IgnorePointer(
                          child: SizedBox(
                            height: cardHeight,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: GenericCredentialCard(
                                credential: credential as VerifiableCredential,
                                canFlip: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Selection indicator - Hidden
                      // Positioned(
                      //   top: 12,
                      //   right: 12,
                      //   child: InkWell(
                      //     onTap: () {
                      //       setState(() {
                      //         if (isSelected) {
                      //           _selectedIndices.remove(i);
                      //         } else {
                      //           _selectedIndices.add(i);
                      //         }
                      //       });
                      //     },
                      //     child: AnimatedContainer(
                      //       duration: const Duration(milliseconds: 200),
                      //       width: 28,
                      //       height: 28,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: isSelected
                      //             ? const Color(0xFF4F39F6)
                      //             : Colors.grey.shade800,
                      //         border: Border.all(color: Colors.white, width: 2),
                      //       ),
                      //       child: isSelected
                      //           ? const Icon(
                      //               Icons.check,
                      //               color: Colors.white,
                      //               size: 18,
                      //             )
                      //           : null,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
