import 'package:flutter/material.dart';

class AyraButton extends StatelessWidget {
  const AyraButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.gradient,
    this.disabledColor = const Color(0xFFBFC9D9),
    this.elevation = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final Color disabledColor;
  final double elevation;
  final EdgeInsets padding;

  static const _defaultGradient = LinearGradient(
    colors: [Color(0xFF00B8DB), Color(0xFF2B7FFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isEnabled ? (gradient ?? _defaultGradient) : null,
            color: isEnabled ? null : disabledColor,
            borderRadius: borderRadius,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: padding,
              child: Center(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    // fontSize left to parent / theme
                  ),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
