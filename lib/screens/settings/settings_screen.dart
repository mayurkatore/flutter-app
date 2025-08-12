import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/constants/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('Light'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).state = value;
                          }
                        },
                      ),
                      onTap: () {
                        ref.read(themeProvider.notifier).state = ThemeMode.light;
                      },
                    ),
                    ListTile(
                      title: const Text('Dark'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).state = value;
                          }
                        },
                      ),
                      onTap: () {
                        ref.read(themeProvider.notifier).state = ThemeMode.dark;
                      },
                    ),
                    ListTile(
                      title: const Text('System Default'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).state = value;
                          }
                        },
                      ),
                      onTap: () {
                        ref.read(themeProvider.notifier).state = ThemeMode.system;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unplug - Digital Wellness App',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text('Version 1.0.0'),
                    const SizedBox(height: 10),
                    const Text(
                      'Helping students develop healthier relationships with technology.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}