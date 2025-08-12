import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = maxWidth ?? constraints.maxWidth;
        double horizontalPadding = padding ?? _getHorizontalPadding(constraints.maxWidth);
        
        return Align(
          alignment: alignment,
          child: Container(
            width: containerWidth,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        );
      },
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) {
      return 200; // Large screens
    } else if (screenWidth > 800) {
      return 100; // Medium screens
    } else if (screenWidth > 600) {
      return 50;  // Small tablets
    } else {
      return 16;  // Mobile devices
    }
  }
}