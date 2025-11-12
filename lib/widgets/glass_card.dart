import 'dart:ui';
import 'package:flutter/material.dart';

/// Widget Glass Card dengan efek glassmorphism
/// Menggunakan BackdropFilter untuk efek blur dan semi-transparan
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        // Warna semi transparan untuk glass effect
        color: Colors.white.withValues(alpha:0.7),
        borderRadius: BorderRadius.circular(24),
        // Border subtle untuk depth
        border: Border.all(
          color: Colors.white.withValues(alpha:0.5),
          width: 1.5,
        ),
        // Shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          // Blur effect untuk glassmorphism
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Gradient subtle untuk depth
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha:0.8),
                  Colors.white.withValues(alpha:0.6),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}