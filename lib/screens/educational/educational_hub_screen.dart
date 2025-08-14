import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'educational_content_screen.dart';

class EducationalHubScreen extends StatelessWidget {
  const EducationalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digital Wellness Resources',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Learn about healthy technology habits and digital wellness.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Infographic Section
            const Text(
              'Infographics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfographicCard(
              context,
              title: 'Screen Time Statistics',
              description:
                  'Learn about average screen time and its effects on health.',
              icon: Icons.bar_chart,
            ),
            const SizedBox(height: 10),
            _buildInfographicCard(
              context,
              title: 'Healthy Phone Habits',
              description:
                  'Tips for developing a healthier relationship with your phone.',
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 10),
            _buildInfographicCard(
              context,
              title: 'Sleep and Technology',
              description:
                  'How technology affects sleep quality and tips for better rest.',
              icon: Icons.bedtime,
            ),
            const SizedBox(height: 30),

            // Quiz Section
            const Text(
              'Quizzes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildQuizCard(
              context,
              title: 'Digital Wellness Quiz',
              description:
                  'Test your knowledge about healthy technology habits.',
              questions: 10,
            ),
            const SizedBox(height: 10),
            _buildQuizCard(
              context,
              title: 'Focus Challenge Quiz',
              description:
                  'Assess your ability to maintain focus without distractions.',
              questions: 8,
            ),
            const SizedBox(height: 30),

            // Articles Section
            const Text(
              'Articles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildArticleCard(
              context,
              title: 'The Science of Digital Detox',
              description:
                  'Understanding the psychological benefits of reducing screen time.',
              readTime: '5 min read',
            ),
            const SizedBox(height: 10),
            _buildArticleCard(
              context,
              title: 'Building Better Habits',
              description:
                  'How to create lasting changes in your technology usage.',
              readTime: '7 min read',
            ),
          ],
        ),
      ),
    );
  }

  List<QuizQuestion> _getQuizQuestions(String quizTitle) {
    if (quizTitle == 'Digital Wellness Quiz') {
      return [
        QuizQuestion(
          question:
              'What is the recommended maximum daily screen time for adults?',
          options: [
            '2 hours',
            '4 hours',
            '8 hours',
            'There is no recommended limit'
          ],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question:
              'Which of the following is NOT a sign of digital eye strain?',
          options: ['Dry eyes', 'Headaches', 'Improved vision', 'Neck pain'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question: 'What is the 20-20-20 rule?',
          options: [
            'Look at something 20 feet away for 20 seconds every 20 minutes',
            'Exercise for 20 minutes, 20 times a day',
            'Drink 20 ounces of water every 20 minutes',
            'Take 20 steps every 20 minutes'
          ],
          correctAnswerIndex: 0,
        ),
        QuizQuestion(
          question:
              'Which practice can help improve sleep quality in relation to device usage?',
          options: [
            'Using devices in bed',
            'Keeping devices on during sleep',
            'Charging devices next to the bed',
            'Avoiding screens 1 hour before bedtime'
          ],
          correctAnswerIndex: 3,
        ),
        QuizQuestion(
          question: 'What is one benefit of digital detox?',
          options: [
            'Increased screen time',
            'Reduced physical activity',
            'Improved face-to-face social interactions',
            'More time spent on social media'
          ],
          correctAnswerIndex: 2,
        ),
      ];
    } else if (quizTitle == 'Focus Challenge Quiz') {
      return [
        QuizQuestion(
          question: 'What is the primary benefit of time-blocking?',
          options: [
            'Increases multitasking',
            'Helps prioritize tasks and manage time effectively',
            'Eliminates all distractions',
            'Reduces the need for breaks'
          ],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question:
              'Which technique involves working for a set period followed by a short break?',
          options: [
            'Time-blocking',
            'Multitasking',
            'The Pomodoro Technique',
            'Procrastination'
          ],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question:
              'What is a common distraction during focused work sessions?',
          options: [
            'Natural lighting',
            'Silence',
            'Social media notifications',
            ' ergonomic chair'
          ],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question: 'How long should a typical Pomodoro work session last?',
          options: ['15 minutes', '25 minutes', '45 minutes', '1 hour'],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question:
              'What is the benefit of setting specific goals for focused work sessions?',
          options: [
            'Increases procrastination',
            'Provides clarity and direction for the work to be done',
            'Eliminates the need for breaks',
            'Reduces productivity'
          ],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question: 'Which environment is most conducive to focused work?',
          options: [
            'Noisy cafeteria',
            'Quiet library or dedicated workspace',
            'Living room with TV on',
            'Bedroom with phone nearby'
          ],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question:
              'What is the recommended action when you notice your mind wandering during a focus session?',
          options: [
            'Continue multitasking',
            'Immediately check social media',
            'Gently redirect attention back to the task',
            'Give up and take a long break'
          ],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question:
              'Why is it important to take regular breaks during focused work sessions?',
          options: [
            'To increase screen time',
            'To prevent mental fatigue and maintain productivity',
            'To avoid completing tasks',
            'To encourage multitasking'
          ],
          correctAnswerIndex: 1,
        ),
      ];
    } else {
      // Default empty list if quiz title doesn't match
      return [];
    }
  }

  Widget _buildInfographicCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to educational content screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EducationalContentScreen(
                title: title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required String title,
    required String description,
    required int questions,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, size: 30, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text('$questions questions'),
                  backgroundColor: colorScheme.primary.withAlpha(26),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Start quiz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      title: title,
                      questions: _getQuizQuestions(title),
                    ),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String description,
    required String readTime,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    readTime,
                    style: TextStyle(color: colorScheme.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to educational content screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EducationalContentScreen(
                          title: title,
                        ),
                      ),
                    );
                  },
                  child: const Text('Read'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
