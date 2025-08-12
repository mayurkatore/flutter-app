# Unplug App - Project Setup Plan

## Project Configuration Changes

### 1. Update pubspec.yaml

We need to update the pubspec.yaml file with the following changes:

1. Change the project name from "app" to "unplug"
2. Update the description to "A student-focused mobile disaddiction and digital wellness app."
3. Update the SDK version to ^3.5.0 to ensure Flutter 3.x compatibility
4. Add the following dependencies:
   - flutter_riverpod: ^2.5.1 (State management)
   - riverpod_annotation: ^2.3.5 (Riverpod code generation)
   - animations: ^2.0.11 (For smooth transitions)
   - flutter_svg: ^2.0.10+1 (For SVG image support)
   - percent_indicator: ^4.2.3 (For progress indicators)
   - intl: ^0.19.0 (For date/time formatting)
   - shared_preferences: ^2.3.2 (For local data persistence)
   - flutter_local_notifications: ^17.2.3 (For notifications)

5. Add dev dependencies:
   - flutter_lints: ^4.0.0
   - riverpod_generator: ^2.4.3
   - build_runner: ^2.4.12
   - custom_lint: ^0.6.8

### 2. Folder Structure

We'll implement the following scalable folder structure:

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
│   ├── dashboard/
│   ├── focus/
│   ├── challenges/
│   ├── journal/
│   └── common/
├── services/
├── utils/
└── routes/
```

### 3. Main Application Structure

The main application will feature:
- Bottom navigation with 4 tabs: Dashboard, Focus, Challenges, Journal
- Theme management for dark/light mode
- Riverpod for state management
- Responsive layout design
- Smooth animations and transitions

### 4. Implementation Steps

1. Update pubspec.yaml (requires switching to Code mode)
2. Create the folder structure
3. Set up main.dart with MaterialApp and theme configuration
4. Implement the bottom navigation structure
5. Create placeholder screens for each tab
6. Set up Riverpod providers
7. Implement theme switching functionality
8. Add animations and transitions