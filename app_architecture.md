# Unplug App - Architecture Plan

## Folder Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # Main app widget
├── config/
│   ├── theme/
│   │   ├── app_theme.dart    # Theme definitions
│   │   └── theme_notifier.dart # Theme switching logic
│   └── constants/
│       ├── app_colors.dart   # Color constants
│       ├── app_strings.dart  # String constants
│       └── app_dimensions.dart # Dimension constants
├── models/
│   ├── app_usage.dart        # App usage data model
│   ├── challenge.dart        # Challenge data model
│   ├── journal_entry.dart    # Journal entry data model
│   ├── goal.dart             # Goal data model
│   └── user.dart             # User data model
├── providers/
│   ├── theme_provider.dart   # Theme state management
│   ├── app_usage_provider.dart # App usage data provider
│   ├── challenge_provider.dart # Challenge data provider
│   ├── journal_provider.dart # Journal data provider
│   └── goal_provider.dart    # Goal data provider
├── screens/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── usage_chart.dart
│   │       ├── app_list_tile.dart
│   │       └── daily_limit_card.dart
│   ├── focus/
│   │   ├── focus_screen.dart
│   │   └── widgets/
│   │       ├── focus_timer.dart
│   │       ├── app_blocker.dart
│   │       └── preset_selector.dart
│   ├── challenges/
│   │   ├── challenges_screen.dart
│   │   └── widgets/
│   │       ├── challenge_card.dart
│   │       ├── streak_display.dart
│   │       └── badge_display.dart
│   ├── journal/
│   │   ├── journal_screen.dart
│   │   └── widgets/
│   │       ├── mood_tracker.dart
│   │       ├── journal_entry_card.dart
│   │       └── prompt_display.dart
│   └── home/
│       └── home_screen.dart  # Bottom navigation container
├── widgets/
│   ├── common/
│   │   ├── app_bar.dart      # Custom app bar
│   │   ├── bottom_nav.dart   # Bottom navigation
│   │   └── loading_indicator.dart
│   └── shared/
│       ├── animated_progress_bar.dart
│       ├── themed_button.dart
│       └── responsive_container.dart
├── services/
│   ├── usage_service.dart    # App usage tracking
│   ├── notification_service.dart # Local notifications
│   └── storage_service.dart  # Local data storage
├── utils/
│   ├── date_utils.dart       # Date helper functions
│   ├── validation_utils.dart # Input validation
│   └── logger.dart           # Logging utility
└── routes/
    └── app_routes.dart       # Navigation routes
```

## State Management with Riverpod

We'll use Riverpod for state management with the following approach:

1. **Providers**:
   - `ThemeProvider` - Manages app theme (light/dark)
   - `AppUsageProvider` - Manages app usage data
   - `ChallengeProvider` - Manages challenge data and streaks
   - `JournalProvider` - Manages journal entries and mood tracking
   - `GoalProvider` - Manages user goals and progress

2. **Provider Types**:
   - `StateProvider` - For simple state like theme mode
   - `StateNotifierProvider` - For complex state management
   - `FutureProvider` - For async data loading
   - `StreamProvider` - For real-time data updates

## UI/UX Design

### Color Scheme
- Primary: Blue/Purple gradient (focus and productivity)
- Secondary: Green (growth and wellness)
- Background: Light gray / Dark gray (depending on mode)
- Accent: Orange (warnings and alerts)

### Typography
- Headings: Bold, clean fonts
- Body: Readable sans-serif
- Emphasis: Weight and color variations

### Components
1. **Dashboard**:
   - Daily usage chart
   - App usage list with time spent
   - Red-zone alerts for limit exceeded
   - Weekly summary cards

2. **Focus Mode**:
   - Timer with start/pause controls
   - App blocking toggle
   - Preset selection (Study, Sleep, etc.)
   - Progress visualization

3. **Challenges**:
   - Challenge cards with progress
   - Streak counter
   - Badge collection
   - Social sharing options

4. **Journal**:
   - Mood tracking wheel
   - Daily prompts
   - Entry history
   - Reflection cards

## Data Models

### AppUsage
```dart
class AppUsage {
  final String appName;
  final String packageName;
  final Duration todayUsage;
  final Duration weeklyUsage;
  final Duration dailyLimit;
  final bool isBlocked;
}
```

### Challenge
```dart
class Challenge {
  final String id;
  final String title;
  final String description;
  final int duration; // in days
  final DateTime startDate;
  final List<bool> dailyProgress; // completed days
  final bool isCompleted;
  final String badge;
}
```

### JournalEntry
```dart
class JournalEntry {
  final String id;
  final DateTime date;
  final String mood;
  final String prompt;
  final String response;
  final List<String> tags;
}
```

### Goal
```dart
class Goal {
  final String id;
  final String title;
  final String reason; // health, study, sleep
  final Duration weeklyLimit;
  final Duration timeSaved;
  final DateTime startDate;
  final bool isActive;
}
```

## Navigation Flow

```
Main App
├── Dashboard Screen
├── Focus Screen
├── Challenges Screen
└── Journal Screen
```

All screens accessible via bottom navigation bar with persistent state.

## Animations and Transitions

1. **Page Transitions**:
   - Fade transitions between screens
   - Shared axis transitions for related content
   - Staggered animations for lists

2. **Micro-interactions**:
   - Button press effects
   - Progress bar animations
   - Card hover effects
   - Toggle switch animations

3. **Data Visualizations**:
   - Animated charts for usage data
   - Progress indicators with easing
   - Streak counter animations

## Responsive Design

1. **Breakpoints**:
   - Mobile: < 600dp
   - Tablet: >= 600dp

2. **Adaptive Layouts**:
   - Flexible grids
   - Scalable typography
   - Responsive images
   - Orientation handling

## Offline Support

1. **Local Storage**:
   - SharedPreferences for simple data
   - SQLite for complex data structures

2. **Data Synchronization**:
   - Conflict resolution strategies
   - Background sync when online

## Development Roadmap

### Phase 1: Foundation (Core Structure)
1. Update project configuration (pubspec.yaml)
2. Implement folder structure
3. Set up theme management
4. Create main app with bottom navigation
5. Implement Riverpod setup

### Phase 2: Core Features Implementation
1. Dashboard Screen with mock data
2. Focus Mode Screen
3. Challenges Screen
4. Journal Screen

### Phase 3: Advanced Features
1. Goal setting functionality
2. Educational hub
3. Peer group challenges
4. Notifications system

### Phase 4: Polish & Testing
1. Animations and transitions
2. Responsive design implementation
3. Offline support
4. Testing and bug fixes
5. Performance optimization