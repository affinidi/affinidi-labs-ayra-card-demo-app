import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../flip_card/flip_card_controller.dart';

/// A reusable flip card widget that provides a 3D flip animation
/// between a front and back side.
///
/// This widget handles all the animation logic internally and exposes
/// simple properties for customization. It integrates with a global
/// flip card controller to ensure only one card is flipped at a time.
class AyraFlipCard extends ConsumerStatefulWidget {
  const AyraFlipCard({
    super.key,
    required this.cardId,
    required this.frontSide,
    required this.backSide,
    this.canFlip = true,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.onFlip,
  });

  /// Unique identifier for this card (required for global flip coordination)
  final String cardId;

  /// The widget to display on the front of the card
  final Widget frontSide;

  /// The widget to display on the back of the card
  final Widget backSide;

  /// Whether the card can be flipped (defaults to true)
  final bool canFlip;

  /// Duration of the flip animation
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Callback when the card is flipped
  final VoidCallback? onFlip;

  @override
  ConsumerState<AyraFlipCard> createState() => _AyraFlipCardState();
}

class _AyraFlipCardState extends ConsumerState<AyraFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (!widget.canFlip) return;

    // Update global flip state
    ref.read(flipCardControllerProvider.notifier).flipCard(widget.cardId);
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the global flip state
    final flippedCardId = ref.watch(flipCardControllerProvider);
    final shouldBeFlipped = flippedCardId == widget.cardId;

    // Sync local animation state with global state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldBeFlipped && !_showBack) {
        setState(() => _showBack = true);
        _controller.forward();
      } else if (!shouldBeFlipped && _showBack) {
        setState(() => _showBack = false);
        _controller.reverse();
      }
    });

    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          // Determine which side to show based on rotation angle
          final showFront = angle <= pi / 2;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showFront
                ? widget.frontSide
                : Transform(
                    transform: Matrix4.rotationY(pi),
                    alignment: Alignment.center,
                    child: widget.backSide,
                  ),
          );
        },
      ),
    );
  }
}
