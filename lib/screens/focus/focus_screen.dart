import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/focus_provider.dart';
import '../../models/focus_session.dart';
import '../../providers/app_usage_provider.dart';
import '../../models/app_usage.dart';
import '../../widgets/shared/button_functions.dart';
import 'screen_time_page.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Duration _timeLeft = const Duration(minutes: 25);
  bool _isRunning = false;
  FocusPreset _selectedPreset = FocusPreset.study;
  Duration _customDuration = const Duration(minutes: 30);
  List<String> _blockedApps = [];
  List<AppUsage> _appUsageList = [];

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    // In a real app, we would use a timer here
    // For now, we'll just simulate the timer
    // Also, we would block the selected apps here
    _blockApps();
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timeLeft = _getDurationForPreset(_selectedPreset);
    });
  }

  Duration _getDurationForPreset(FocusPreset preset) {
    switch (preset) {
      case FocusPreset.study:
        return const Duration(minutes: 25);
      case FocusPreset.sleep:
        return const Duration(minutes: 10);
      case FocusPreset.work:
        return const Duration(minutes: 45);
      case FocusPreset.custom:
        return _customDuration;
    }
  }

  void _selectPreset(FocusPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _timeLeft = _getDurationForPreset(preset);
    });
  }

  void _toggleAppBlock(String appId) {
    setState(() {
      if (_blockedApps.contains(appId)) {
        _blockedApps.remove(appId);
      } else {
        _blockedApps.add(appId);
      }
    });
  }

  void _blockApps() {
    // In a real app, this would interact with system-level app blocking functionality
    // For now, we'll just update the app usage provider with the blocked apps
    for (final appId in _blockedApps) {
      ref.read(appUsageProvider.notifier).toggleAppBlock(appId);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Focus Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Customize your focus session'),
                const SizedBox(height: 20),
                const Text('Session Duration:'),
                Slider(
                  value: _getDurationForPreset(_selectedPreset)
                      .inMinutes
                      .toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label:
                      '${_getDurationForPreset(_selectedPreset).inMinutes} minutes',
                  onChanged: (double value) {
                    setState(() {
                      if (_selectedPreset == FocusPreset.custom) {
                        _customDuration = Duration(minutes: value.toInt());
                        _timeLeft = _customDuration;
                      } else {
                        // For other presets, we'll update the custom duration as well
                        // so that if the user switches to custom, it has a reasonable value
                        _customDuration = Duration(minutes: value.toInt());
                      }
                    });
                  },
                ),
                Text(
                    '${_getDurationForPreset(_selectedPreset).inMinutes} minutes'),
                const SizedBox(height: 20),
                const Text('Blocked Apps:'),
                const SizedBox(height: 10),
                ..._blockedApps.map((appId) => Text(appId)).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusSessions = ref.watch(focusProvider);
    final appUsageList = ref.watch(appUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        actions: [
          AppButtons.iconButton(
            icon: Icons.settings,
            onPressed: _showSettingsDialog,
            context: context,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer Section
              _buildTimerSection(context),
              const SizedBox(height: 30),

              // Presets Section
              _buildPresetsSection(context),
              const SizedBox(height: 30),

              // App Blocker Section
              _buildAppBlockerSection(context),
              const SizedBox(height: 30),

              // Recent Sessions
              _buildRecentSessionsSection(focusSessions, context),
              const SizedBox(height: 20),

              // Screen Time Button
              _buildScreenTimeButton(context),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          // Circular timer display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _timeLeft.inSeconds /
                      _getDurationForPreset(_selectedPreset).inSeconds,
                  strokeWidth: 10,
                  backgroundColor:
                      colorScheme.onSurfaceVariant.withAlpha(51),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_timeLeft.inMinutes}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _selectedPreset.name.toUpperCase(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButtons.timerControlButton(
                context: context,
                isRunning: _isRunning,
                onStartPause: _isRunning ? _pauseTimer : _startTimer,
              ),
              const SizedBox(width: 20),
              AppButtons.secondaryButton(
                context: context,
                text: 'Reset',
                onPressed: _resetTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Focus Presets',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FocusPreset.values.map((preset) {
            return AppButtons.presetChip(
              label: preset.name,
              isSelected: _selectedPreset == preset,
              onSelected: (selected) {
                if (selected) {
                  _selectPreset(preset);
                }
              },
              context: context,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppBlockerSection(BuildContext context) {
    final mockApps = [
      {'id': 'com.social.media', 'name': 'Social Media App'},
      {'id': 'com.video.streaming', 'name': 'Video Streaming'},
      {'id': 'com.games.app', 'name': 'Games'},
      {'id': 'com.shopping.app', 'name': 'Shopping App'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Block Apps',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: mockApps.map((app) {
            return CheckboxListTile(
              title: Text(app['name']!),
              value: _blockedApps.contains(app['id']),
              onChanged: (bool? value) {
                _toggleAppBlock(app['id']!);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSessionsSection(List focusSessions, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sessions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (focusSessions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No focus sessions yet. Start your first session!'),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: focusSessions.length > 5 ? 5 : focusSessions.length,
              itemBuilder: (context, index) {
                final session = focusSessions[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            session.preset.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${session.duration.inMinutes} minutes',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                          const Spacer(),
                          if (session.isCompleted)
                            const Chip(
                              label: Text('Completed'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildScreenTimeButton(BuildContext context) {
    return Center(
      child: AppButtons.primaryButton(
        context: context,
        text: 'View Screen Time',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenTimePage(),
            ),
          );
        },
      ),
    );
  }
}
