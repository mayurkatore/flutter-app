# Phase 1: Foundation Setup - Implementation Details

## 1. Update pubspec.yaml
Since we're in Architect mode, we can't directly modify the pubspec.yaml file. We need to document the required changes for the Code mode:

### Required Changes:
```yaml
name: unplug
description: "A student-focused mobile disaddiction and digital wellness app."

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  animations: ^2.0.11
  flutter_svg: ^2.0.10+1
  percent_indicator: ^4.2.3
  intl: ^0.19.0
  shared_preferences: ^2.3.2
  flutter_local_notifications: ^17.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.12
  custom_lint: ^0.6.8
```

## 2. Folder Structure Implementation
Create the following directory structure:
```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme/
│   └── constants/
├── models/
├── providers/
├── screens/
│   ├── dashboard/
│   ├── focus/
│   ├── challenges/
│   ├── journal/
│   └── home/
├── widgets/
│   ├── common/
│   └── shared/
├── services/
├── utils/
└── routes/
```

## 3. Riverpod Setup
Create the following files:
- `lib/providers/theme_provider.dart` - For theme management
- `lib/providers/app_usage_provider.dart` - For app usage data
- `lib/providers/challenge_provider.dart` - For challenge data
- `lib/providers/journal_provider.dart` - For journal data

## 4. Theme Management Implementation
Create:
- `lib/config/theme/app_theme.dart` - Define light and dark themes
- `lib/config/theme/theme_notifier.dart` - Theme switching logic
- `lib/config/constants/app_colors.dart` - Color constants
- `lib/config/constants/app_strings.dart` - String constants

## 5. Main App Structure
Modify `lib/main.dart` and create `lib/app.dart` to:
- Set up MaterialApp with theme configuration
- Implement bottom navigation with 4 tabs
- Set up Riverpod providers scope
- Create placeholder screens for each tab

## Implementation Steps:

### Step 1: Create Folder Structure
1. Create all directories listed above
2. Ensure proper file organization

### Step 2: Theme Management
1. Define color palette in `app_colors.dart`
2. Create light theme in `app_theme.dart`
3. Create dark theme in `app_theme.dart`
4. Implement theme switching logic in `theme_notifier.dart`
5. Set up theme provider in `theme_provider.dart`

### Step 3: Main Application Structure
1. Update `main.dart` to use Riverpod and new app structure
2. Create `app.dart` with MaterialApp configuration
3. Implement bottom navigation in a new `home_screen.dart`
4. Create placeholder screens for all four tabs

### Step 4: Riverpod Integration
1. Set up ProviderScope in `main.dart`
2. Create providers for each major feature
3. Implement basic state management patterns

## Code Structure Examples:

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### app.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home/home_screen.dart';
import 'config/theme/app_theme.dart';
import 'providers/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Unplug',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
```

### Home Screen with Bottom Navigation
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_screen.dart';
import '../focus/focus_screen.dart';
import '../challenges/challenges_screen.dart';
import '../journal/journal_screen.dart';
import '../../providers/theme_provider.dart';

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
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
        ],
      ),
    );
  }
}
```

### Theme Provider
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

### App Theme
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
  );
  
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  );
}
```

## Next Steps
After completing Phase 1, we'll move to Phase 2 where we implement the actual screens with mock data. The foundation we're building in Phase 1 will allow us to:

1. Have a clean, scalable architecture
2. Implement proper state management
3. Support both light and dark themes
4. Navigate between the four main sections
5. Easily add new features in the future

This approach ensures we have a solid base before implementing complex features, making the development process more efficient and maintainable.