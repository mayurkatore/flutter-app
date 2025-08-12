import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';

// Mock data for journal entries
final List<JournalEntry> _mockJournalEntries = [
  JournalEntry(
    id: '1',
    date: DateTime.now().subtract(const Duration(days: 1)),
    mood: Mood.happy,
    prompt: 'What are three things you are grateful for today?',
    response: 'I am grateful for my supportive friends, good health, and the beautiful weather.',
    tags: ['gratitude', 'friends', 'health'],
  ),
  JournalEntry(
    id: '2',
    date: DateTime.now().subtract(const Duration(days: 2)),
    mood: Mood.neutral,
    prompt: 'How did you manage your phone usage today?',
    response: 'I tried to limit my social media time and focused on studying instead. It was challenging but I managed to reduce my usage by 30 minutes.',
    tags: ['productivity', 'self-improvement'],
  ),
  JournalEntry(
    id: '3',
    date: DateTime.now().subtract(const Duration(days: 3)),
    mood: Mood.veryHappy,
    prompt: 'What made you smile today?',
    response: 'My friend surprised me with my favorite coffee and we had a great conversation about our future plans.',
    tags: ['friends', 'happiness'],
  ),
];

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super(_mockJournalEntries);

  void addJournalEntry(JournalEntry entry) {
    state = [entry, ...state];
  }

  void removeJournalEntry(String entryId) {
    state = state.where((entry) => entry.id != entryId).toList();
  }

  void updateJournalEntry(String entryId, String newResponse) {
    state = [
      for (final entry in state)
        if (entry.id == entryId)
          entry.copyWith(response: newResponse)
        else
          entry
    ];
  }
}