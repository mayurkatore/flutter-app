import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final Duration animationDuration;
  final BorderRadius borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.onSurfaceVariant.withAlpha(77),
            borderRadius: borderRadius,
          ),
          child: AnimatedContainer(
            duration: animationDuration,
            width: constraints.maxWidth * value,
            decoration: BoxDecoration(
              color: color ?? colorScheme.primary,
              borderRadius: borderRadius,
            ),
          ),
        );
      },
    );
  }
}