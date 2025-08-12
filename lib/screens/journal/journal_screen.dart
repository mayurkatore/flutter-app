import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_entry.dart';
import 'new_journal_entry_screen.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalEntries = ref.watch(journalProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              // Navigate to new journal entry screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewJournalEntryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Tracker Section
            _buildMoodTracker(context),
            const SizedBox(height: 30),
            
            // Recent Entries Section
            const Text(
              'Recent Entries',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildJournalEntriesList(journalEntries, context, ref),
            ),
          ],
        ),
      ),
    );
  }
  
  void _deleteJournalEntry(String entryId, WidgetRef ref, BuildContext context) async {
    // Show a confirmation dialog before deleting
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Journal Entry'),
          content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    
    // If user confirmed deletion, proceed with deleting the entry
    if (confirmDelete == true) {
      ref.read(journalProvider.notifier).removeJournalEntry(entryId);
      
      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry deleted')),
      );
    }
  }
  
  void _editJournalEntry(JournalEntry entry, WidgetRef ref, BuildContext context) async {
    // Show a dialog with a text field to edit the response
    TextEditingController controller = TextEditingController(text: entry.response);
    
    String? newResponse = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Journal Entry'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your response',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    // If user saved changes, update the entry
    if (newResponse != null && newResponse != entry.response) {
      ref.read(journalProvider.notifier).updateJournalEntry(entry.id, newResponse);
      
      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry updated')),
      );
    }
  }

  Widget _buildMoodTracker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodOption(Mood.veryHappy, Icons.sentiment_very_satisfied, 'Very Happy', context),
                _buildMoodOption(Mood.happy, Icons.sentiment_satisfied, 'Happy', context),
                _buildMoodOption(Mood.neutral, Icons.sentiment_neutral, 'Neutral', context),
                _buildMoodOption(Mood.sad, Icons.sentiment_dissatisfied, 'Sad', context),
                _buildMoodOption(Mood.verySad, Icons.sentiment_very_dissatisfied, 'Very Sad', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(Mood mood, IconData icon, String label, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: _getMoodColor(mood)),
          onPressed: () {
            // Handle mood selection
            // In a real app, you might want to save this to a provider or state management solution
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You selected: $label')),
            );
          },
        ),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return Colors.green;
      case Mood.happy:
        return Colors.lightGreen;
      case Mood.neutral:
        return Colors.grey;
      case Mood.sad:
        return Colors.orange;
      case Mood.verySad:
        return Colors.red;
    }
  }

  Widget _buildJournalEntriesList(List<JournalEntry> entries, BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No journal entries yet. Create your first entry!'),
      );
    }

    // Sort by date (newest first)
    final sortedEntries = List.from(entries)..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return _buildJournalEntryCard(entry, context, ref);
      },
    );
  }

  Widget _buildJournalEntryCard(JournalEntry entry, BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildMoodIcon(entry.mood),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.primary),
                      onPressed: () {
                        // Edit the journal entry
                        _editJournalEntry(entry, ref, context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () {
                        // Delete the journal entry
                        _deleteJournalEntry(entry.id, ref, context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.prompt,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(entry.response),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: entry.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIcon(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      case Mood.happy:
        return const Icon(Icons.sentiment_satisfied, color: Colors.lightGreen);
      case Mood.neutral:
        return const Icon(Icons.sentiment_neutral, color: Colors.grey);
      case Mood.sad:
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.orange);
      case Mood.verySad:
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}