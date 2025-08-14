import 'package:flutter/material.dart';

/// A collection of reusable button widgets for the app
class AppButtons {
  /// Creates a primary action button with rounded corners
  static Widget primaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(text),
    );
  }

  /// Creates a secondary action button with rounded corners
  static Widget secondaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(text),
    );
  }

  /// Creates an icon button with specified color
  static Widget iconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, color: colorScheme.onSurfaceVariant),
      onPressed: onPressed,
    );
  }

  /// Creates a start/pause button for the focus timer
  static Widget timerControlButton({
    required BuildContext context,
    required bool isRunning,
    required VoidCallback onStartPause,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onStartPause,
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunning ? colorScheme.secondary : colorScheme.primary,
        foregroundColor: isRunning ? colorScheme.onSecondary : colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(isRunning ? 'Pause' : 'Start'),
    );
  }

  /// Creates a choice chip for focus presets
  static Widget presetChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label.toUpperCase()),
      selected: isSelected,
      selectedColor: colorScheme.primary.withAlpha(51), // ~20% opacity
      onSelected: onSelected,
    );
  }
}
