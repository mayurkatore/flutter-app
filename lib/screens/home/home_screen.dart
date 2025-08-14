import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_screen.dart';
import '../focus/focus_screen.dart';
import '../challenges/challenges_screen.dart';
import '../journal/journal_screen.dart';
import '../educational/educational_hub_screen.dart';
import '../social/social_screen.dart';
import '../goals/goal_setting_screen.dart';
import '../../widgets/common/draggable_theme_toggle.dart';
import '../settings/settings_screen.dart';
import '../testing/testing_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FocusScreen(),
    const ChallengesScreen(),
    const JournalScreen(),
    const EducationalHubScreen(),
    const SocialScreen(),
    const GoalSettingScreen(),
    const SettingsScreen(),
    const TestingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                label: 'Focus',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                label: 'Challenges',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Journal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Social',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                label: 'Goals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Testing',
              ),
            ],
          ),
        ),
        const DraggableThemeToggle(),
      ],
    );
  }
}
