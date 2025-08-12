import 'package:flutter/material.dart';

class CustomAnimations {
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget slideTransition({
    required Widget child,
    required Animation<Offset> animation,
  }) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double? begin,
    double? end,
  }) {
    begin ??= 0.0;
    end ??= 1.0;
    
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(animation),
      child: child,
    );
  }

  static Widget rotationTransition({
    required Widget child,
    required Animation<double> animation,
    double? begin,
    double? end,
  }) {
    begin ??= 0.0;
    end ??= 1.0;
    
    return RotationTransition(
      turns: Tween<double>(
        begin: begin,
        end: end,
      ).animate(animation),
      child: child,
    );
  }

  static Widget staggeredTransition({
    required Widget child,
    required Animation<double> animation,
    required int index,
    int totalItems = 10,
  }) {
    final animationDelay = index / totalItems;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        animationDelay,
        animationDelay + (1.0 / totalItems),
        curve: Curves.easeInOut,
      ),
    );
    
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  static Widget bounceTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ),
      ),
      child: child,
    );
  }

  static Widget flipTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value * 3.14159),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}