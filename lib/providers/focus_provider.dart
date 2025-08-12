import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';

// Mock data for focus sessions
final List<FocusSession> _mockFocusSessions = [
  FocusSession(
    id: '1',
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    endTime: DateTime.now().subtract(const Duration(minutes: 30)),
    duration: const Duration(hours: 1),
    preset: FocusPreset.study,
    blockedApps: ['com.social.media', 'com.video.streaming'],
    isCompleted: true,
  ),
  FocusSession(
    id: '2',
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    duration: const Duration(hours: 1),
    preset: FocusPreset.work,
    blockedApps: ['com.games.app', 'com.social.media'],
    isCompleted: true,
  ),
];

final focusProvider = StateNotifierProvider<FocusNotifier, List<FocusSession>>((ref) {
  return FocusNotifier();
});

class FocusNotifier extends StateNotifier<List<FocusSession>> {
  FocusNotifier() : super(_mockFocusSessions);

  void addFocusSession(FocusSession session) {
    state = [session, ...state];
  }

  void removeFocusSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
  }

  void updateFocusSession(String sessionId, {DateTime? endTime, bool? isCompleted}) {
    state = [
      for (final session in state)
        if (session.id == sessionId)
          session.copyWith(
            endTime: endTime,
            isCompleted: isCompleted,
          )
        else
          session
    ];
  }
}