import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_entry.dart';

class NewJournalEntryScreen extends ConsumerStatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  ConsumerState<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends ConsumerState<NewJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _responseController;
  late TextEditingController _tagController;
  Mood _selectedMood = Mood.neutral;
  List<String> _tags = [];
  String _prompt = 'How are you feeling today?';

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      final newEntry = JournalEntry(
        id: DateTime.now().toString(),
        date: DateTime.now(),
        mood: _selectedMood,
        prompt: _prompt,
        response: _responseController.text,
        tags: _tags,
      );

      ref.read(journalProvider.notifier).addJournalEntry(newEntry);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: colorScheme.onSurfaceVariant),
            onPressed: _submitEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Selector
              const Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodOption(Mood.veryHappy, Icons.sentiment_very_satisfied, 'Very Happy'),
                  _buildMoodOption(Mood.happy, Icons.sentiment_satisfied, 'Happy'),
                  _buildMoodOption(Mood.neutral, Icons.sentiment_neutral, 'Neutral'),
                  _buildMoodOption(Mood.sad, Icons.sentiment_dissatisfied, 'Sad'),
                  _buildMoodOption(Mood.verySad, Icons.sentiment_very_dissatisfied, 'Very Sad'),
                ],
              ),
              const SizedBox(height: 20),

              // Prompt
              const Text(
                'Prompt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _prompt,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a prompt for your journal entry',
                ),
                onChanged: (value) {
                  setState(() {
                    _prompt = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a prompt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Response
              const Text(
                'Your Response',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TextFormField(
                  controller: _responseController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your journal entry here...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write your journal entry';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Tags
              const Text(
                'Tags',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add a tag',
                      ),
                      onFieldSubmitted: _addTag,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: colorScheme.primary),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption(Mood mood, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        IconButton(
          icon: Icon(icon, 
            size: 30, 
            color: _selectedMood == mood ? colorScheme.primary : _getMoodColor(mood)),
          onPressed: () {
            setState(() {
              _selectedMood = mood;
            });
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
}