import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable glassmorphism card with frosted backdrop blur,
/// rounded corners, hairline highlight border, and subtle elevation shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? tintColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 24,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(4, 10, 28, 0.32),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor ?? const Color.fromRGBO(255, 255, 255, 0.09),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.16),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
