import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/screen_time_service.dart';
import '../../services/healthy_habits_service.dart';
import '../../services/night_mode_service.dart' as night_mode;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_usage.dart';

class EducationalContentScreen extends ConsumerStatefulWidget {
  final String title;

  const EducationalContentScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<EducationalContentScreen> createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState
    extends ConsumerState<EducationalContentScreen> {
  bool _loadingStats = false;
  bool _hasPermission = false;
  List<AppUsage> _screenTimeStats = [];
  Map<String, int> _appTimeLimits = {};
  Map<String, TextEditingController> _timeLimitControllers = {};
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  
  // Bedtime reminder variables
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  bool _reminderEnabled = false;

  final List<String> _sampleApps = [
    'com.whatsapp',
    'com.facebook.katana',
    'com.instagram.android',
    'com.twitter.android',
    'com.google.android.youtube',
  ];

  @override
  void initState() {
    super.initState();
    _loadScreenTimeStats();
    _loadAppTimeLimits();
    _loadBedtimeSettings();
  }

  @override
  void dispose() {
    for (final controller in _timeLimitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadScreenTimeStats() async {
    setState(() {
      _loadingStats = true;
    });

    try {
      // Check if we have usage permission
      bool granted = await _screenTimeService.requestUsagePermission();
      setState(() {
        _hasPermission = granted;
      });

      if (_hasPermission) {
        // Get stats for the past 24 hours
        Map<String, Duration> stats =
            await _screenTimeService.getDailyScreenTimeStats();

        // Convert to AppUsage format for display
        List<AppUsage> appUsageList = stats.entries.map((entry) {
          return AppUsage(
            id: entry.key,
            appName: entry.key,
            packageName: entry.key,
            todayUsage: entry.value,
            weeklyUsage: entry.value,
            dailyLimit: const Duration(hours: 1),
            isBlocked: false,
            lastUsed: DateTime.now(),
          );
        }).toList();

        // Sort by usage time (descending)
        appUsageList.sort((a, b) {
          return b.todayUsage.compareTo(a.todayUsage);
        });

        setState(() {
          _screenTimeStats = appUsageList;
        });
      }
    } catch (e) {
      debugPrint('Error loading screen time stats: $e');
    } finally {
      setState(() {
        _loadingStats = false;
      });
    }
  }

  Future<void> _requestScreenTimePermission() async {
    try {
      bool granted = await _screenTimeService.requestUsagePermission();
      setState(() {
        _hasPermission = granted;
      });
      // Reload stats after granting permission
      if (granted) {
        _loadScreenTimeStats();
      }
    } catch (e) {
      debugPrint('Error requesting screen time permission: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to request permission. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _loadAppTimeLimits() async {
    try {
      _appTimeLimits = await HealthyHabitsService.getAppTimeLimits();
      // Initialize controllers for each app
      for (final app in _sampleApps) {
        _timeLimitControllers[app] = TextEditingController(
          text: _appTimeLimits[app]?.toString() ?? '',
        );
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error loading app time limits: $e');
    }
  }

  Future<void> _saveAppTimeLimit(String packageName) async {
    final controller = _timeLimitControllers[packageName];
    if (controller == null) return;

    final limitText = controller.text;
    if (limitText.isEmpty) {
      // Remove the limit
      await HealthyHabitsService.removeAppTimeLimit(packageName);
      setState(() {
        _appTimeLimits.remove(packageName);
      });
    } else {
      final limit = int.tryParse(limitText);
      if (limit != null && limit > 0) {
        await HealthyHabitsService.saveAppTimeLimit(packageName, limit);
        setState(() {
          _appTimeLimits[packageName] = limit;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time limit saved')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid time limit')),
          );
        }
      }
    }
  }

  Future<void> _loadBedtimeSettings() async {
    try {
      // Load bedtime from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('bedtime_hour') ?? 21; // Default 9 PM
      final minute = prefs.getInt('bedtime_minute') ?? 0; // Default 0 minutes
      setState(() {
        _bedtime = TimeOfDay(hour: hour, minute: minute);
      });

      // Check if reminder is enabled
      final enabled = prefs.getBool('bedtime_reminder_enabled') ?? false;
      setState(() {
        _reminderEnabled = enabled;
      });

      // If enabled, initialize the notification service
      if (_reminderEnabled) {
        await night_mode.NightModeService.initialize();
      }
    } catch (e) {
      debugPrint('Error loading bedtime settings: $e');
    }
  }

  Future<void> _saveBedtimeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bedtime_hour', _bedtime.hour);
      await prefs.setInt('bedtime_minute', _bedtime.minute);
      await prefs.setBool('bedtime_reminder_enabled', _reminderEnabled);

      // Handle notification scheduling/canceling
      if (_reminderEnabled) {
        await night_mode.NightModeService.initialize();
        await night_mode.NightModeService.scheduleBedtimeReminder(
          bedtime: night_mode.TimeOfDay(_bedtime.hour, _bedtime.minute),
          title: 'Bedtime Reminder',
          body: 'Avoid screens for better sleep!',
        );
      } else {
        await night_mode.NightModeService.cancelBedtimeReminder();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bedtime settings saved')),
        );
      }
    } catch (e) {
      debugPrint('Error saving bedtime settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (widget.title == 'Screen Time Statistics')
              _buildScreenTimeContent(colorScheme)
            else if (widget.title == 'Healthy Phone Habits')
              _buildHealthyHabitsContent(colorScheme)
            else if (widget.title == 'Sleep and Technology')
              _buildSleepTechnologyContent(colorScheme)
            else if (widget.title == 'The Science of Digital Detox')
              _buildDigitalDetoxContent(colorScheme)
            else if (widget.title == 'Building Better Habits')
              _buildBuildingHabitsContent(colorScheme)
            else
              const Text('Content not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Screen Time Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Avg. adult: 6–7 hrs/day on screens.\n\nTeens: 7–9 hrs/day.\n\n'
          'Too much screen time can cause eye strain, poor sleep, anxiety, and low activity.',
        ),
        const SizedBox(height: 10),
        const Text(
          '💡 Track with Digital Wellbeing or iOS Screen Time.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        if (!_hasPermission)
          Column(
            children: [
              const Text(
                'To view your actual screen time statistics, please grant usage access permission.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _requestScreenTimePermission,
                child: const Text('Grant Usage Access Permission'),
              ),
            ],
          )
        else if (_loadingStats)
          const Center(child: CircularProgressIndicator())
        else if (_screenTimeStats.isEmpty)
          const Text('No screen time data available.')
        else
          _buildScreenTimeStatsList(colorScheme),
      ],
    );
  }

  Widget _buildScreenTimeStatsList(ColorScheme colorScheme) {
    Duration totalScreenTime = Duration.zero;
    for (var info in _screenTimeStats) {
      totalScreenTime += info.todayUsage;
    }

    final totalHours = totalScreenTime.inHours;
    final totalMinutes = totalScreenTime.inMinutes.remainder(60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Screen Time: $totalHours h $totalMinutes m',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your top used apps (last 24 hours):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (var info in _screenTimeStats.take(10))
          _buildAppUsageItem(info, colorScheme),
      ],
    );
  }

  Widget _buildAppUsageItem(AppUsage info, ColorScheme colorScheme) {
    final hours = info.todayUsage.inHours;
    final minutes = info.todayUsage.inMinutes.remainder(60);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // App icon would go here in a real app
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.android,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.appName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$hours h $minutes m',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthyHabitsContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Healthy Phone Habits',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Set app limits.\n\nTurn off unneeded notifications.\n\n'
          'Keep phone-free times (meals, bedtime).\n\nUse Do Not Disturb to focus.',
        ),
        const SizedBox(height: 10),
        const Text(
          '💡 Small breaks = better focus & mood.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set custom time limits for your apps:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (final app in _sampleApps)
          _buildAppTimeLimitSetting(app, colorScheme),
      ],
    );
  }

  Widget _buildAppTimeLimitSetting(
      String packageName, ColorScheme colorScheme) {
    final appName = _getAppName(packageName);
    final controller =
        _timeLimitControllers[packageName] ?? TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Time limit (minutes)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _saveAppTimeLimit(packageName),
                  child: const Text('Save'),
                ),
              ],
            ),
            if (_appTimeLimits.containsKey(packageName))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Current limit: ${HealthyHabitsService.formatMinutes(_appTimeLimits[packageName]!)}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getAppName(String packageName) {
    switch (packageName) {
      case 'com.instagram.android':
        return 'Instagram';
      case 'com.facebook.katana':
        return 'Facebook';
      case 'com.whatsapp':
        return 'WhatsApp';
      case 'com.google.android.youtube':
        return 'YouTube';
      case 'com.netflix.mediaclient':
        return 'Netflix';
      default:
        return packageName;
    }
  }

  Widget _buildSleepTechnologyContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep and Technology',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Screens at night → less melatonin → harder to sleep.\n\n'
          'Notifications disturb deep sleep.',
        ),
        const SizedBox(height: 10),
        const Text(
          '💡 Tips:\n\nNo screens 1 hr before bed.\n\nUse night mode.\n\nKeep phone away from bed.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set a bedtime reminder:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bedtime Reminder',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _reminderEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                if (_reminderEnabled) ...[
                  const SizedBox(height: 10),
                  const Text('Set your bedtime:'),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${_bedtime.hour}:${_bedtime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _selectBedtime,
                        child: const Text('Change Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You will receive a notification 1 hour before bedtime to remind you to avoid screens.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveBedtimeSettings,
                    child: const Text('Save Settings'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBedtime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
    );
    if (picked != null && picked != _bedtime) {
      setState(() {
        _bedtime = picked;
      });
    }
  }
  
  Widget _buildDigitalDetoxContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is a Digital Detox?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'A digital detox is a conscious break from screens — smartphones, laptops, TVs, and gaming consoles — to give your mind and body a chance to reset.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Why Our Brains Need It',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Every ping, like, or notification triggers dopamine — the brain\'s "reward chemical." This creates a habit loop that makes it hard to look away. Over time, this can lead to:',
        ),
        const SizedBox(height: 10),
        const Text(
          '• Shorter attention spans',
        ),
        const Text(
          '• Difficulty sleeping due to blue light exposure',
        ),
        const Text(
          '• Higher stress levels from constant information flow',
        ),
        const SizedBox(height: 20),
        const Text(
          'Benefits You\'ll Notice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sharper Focus → Without interruptions, your brain can stay in deep concentration longer.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Improved Mood → Less exposure to negative or unrealistic content.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Stronger Relationships → More face-to-face time with family and friends.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Better Health → Reduced eye strain, headaches, and better posture.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Quick Detox Tips',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '1. No-Screen Mornings – Avoid devices for the first hour of your day.',
        ),
        const SizedBox(height: 5),
        const Text(
          '2. Set Boundaries – Use app blockers to control time-wasting apps.',
        ),
        const SizedBox(height: 5),
        const Text(
          '3. Find Offline Joy – Read, walk, paint, or cook instead of scrolling.',
        ),
        const SizedBox(height: 5),
        const Text(
          '4. One Device Rule – No phone while watching TV or eating meals.',
        ),
      ],
    );
  }
  
  Widget _buildBuildingHabitsContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How Habits Work',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Habits follow a cue → routine → reward cycle. To change a habit, you must change the routine triggered by the cue — while still rewarding yourself in a healthy way.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Steps to Build Healthy Tech Habits',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '1. Start Small → Reduce daily screen time by 15–20 minutes instead of making huge cuts.',
        ),
        const SizedBox(height: 5),
        const Text(
          '2. Change Your Environment → Keep your phone in another room during work or sleep.',
        ),
        const SizedBox(height: 5),
        const Text(
          '3. Swap Bad with Good → Listen to a podcast or audiobook instead of endlessly scrolling.',
        ),
        const SizedBox(height: 5),
        const Text(
          '4. Track Progress → Use a journal or a habit tracker app to stay motivated.',
        ),
        const SizedBox(height: 5),
        const Text(
          '5. Reward Yourself → Treat yourself after a week of meeting your tech goals.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Real-Life Examples',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Phone-Free Bedroom → Charge your phone outside your room at night.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Tech-Free Meals → Have at least one device-free meal each day.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Focus Hours → Silence notifications during study or work blocks.',
        ),
        const SizedBox(height: 5),
        const Text(
          'Notification Declutter → Turn off all non-essential app alerts.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Why It Works',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'When practiced consistently, these small actions become automatic. Over time, you\'ll notice more free time, better focus, improved sleep, and a healthier relationship with technology.',
        ),
      ],
    );
  }
}
