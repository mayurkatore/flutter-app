import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge.dart';
import 'create_challenge_screen.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              // Navigate to create challenge screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateChallengeScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Challenges Section
              const Text(
                'Active Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildChallengesList(challenges.where((c) => !c.isCompleted).toList(), ref, context),
              const SizedBox(height: 30),
              
              // Completed Challenges Section
              const Text(
                'Completed Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildChallengesList(challenges.where((c) => c.isCompleted).toList(), ref, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesList(List<Challenge> challenges, WidgetRef ref, BuildContext context) {
    if (challenges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No challenges found.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge, context, ref);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge, BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (challenge.isCompleted)
                  const Chip(
                    label: Text('Completed'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              challenge.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            
            // Progress bar
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: colorScheme.onSurfaceVariant.withAlpha(51),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(challenge.progressPercentage * 100).round()}% Complete',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${challenge.currentStreak} day streak',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Daily progress indicators
            _buildDailyProgressIndicators(challenge, context),
            const SizedBox(height: 10),
            
            // Badge info
            if (challenge.badgeName.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: colorScheme.primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Badge: ${challenge.badgeName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
            // Action buttons
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Mark today as complete
                    ref.read(challengeProvider.notifier).markTodayComplete(challenge.id);
                    // Show a snackbar to confirm the action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Today marked as complete!')),
                    );
                  },
                  child: const Text('Mark Today'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    // View details
                  },
                  child: const Text('Details'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Warrior, Aware, and Early Bird challenges
            if (challenge.title == 'Weekend Warrior Challenge' ||
                challenge.title == 'Aware Challenge' ||
                challenge.title == 'Early Bird Challenge')
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: colorScheme.primary),
                    const SizedBox(width: 5),
                    const Text(
                      'Special Challenge',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgressIndicators(Challenge challenge, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(challenge.duration, (index) {
          bool isCompleted = index < challenge.dailyProgress.length && challenge.dailyProgress[index];
          bool isCurrentDay = index == challenge.dailyProgress.length;
          
          return Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : (isCurrentDay ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 15)
                    : null,
              ),
              const SizedBox(height: 5),
              Text(
                'D${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrentDay ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}