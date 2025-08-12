class JournalEntry {
  final String id;
  final DateTime date;
  final Mood mood;
  final String prompt;
  final String response;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.prompt,
    required this.response,
    required this.tags,
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    String? prompt,
    String? response,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, date: $date, mood: $mood, prompt: $prompt, response: $response, tags: $tags)';
  }
}

enum Mood {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}