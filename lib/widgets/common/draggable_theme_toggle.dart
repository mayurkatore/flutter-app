import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';

class DraggableThemeToggle extends ConsumerStatefulWidget {
  const DraggableThemeToggle({super.key});

  @override
  ConsumerState<DraggableThemeToggle> createState() => _DraggableThemeToggleState();
}

class _DraggableThemeToggleState extends ConsumerState<DraggableThemeToggle> {
  Offset _position = const Offset(100, 100); // Default position
  double _buttonSize = 56.0; // Default FAB size

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble('theme_toggle_x') ?? 100.0;
    final dy = prefs.getDouble('theme_toggle_y') ?? 100.0;
    setState(() {
      _position = Offset(dx, dy);
    });
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('theme_toggle_x', _position.dx);
    await prefs.setDouble('theme_toggle_y', _position.dy);
  }

  void _toggleTheme() {
    ref.read(themeProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });
            },
            onPanEnd: (details) {
              _savePosition();
            },
            child: Material(
              color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.secondary,
              shape: const CircleBorder(),
              elevation: 4.0,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.secondary,
                ),
                child: IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
                  ),
                  onPressed: _toggleTheme,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}