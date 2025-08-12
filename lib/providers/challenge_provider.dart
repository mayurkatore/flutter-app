import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';

// Mock data for challenges
final List<Challenge> _mockChallenges = [
  Challenge(
    id: '1',
    title: '7-Day Social Media Detox',
    description: 'Avoid all social media platforms for 7 days',
    duration: 7,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    dailyProgress: [true, true, false, false, false, false, false],
    isCompleted: false,
    badgeName: 'Digital Detox Beginner',
    type: ChallengeType.daily,
    groupId: 'group1', // Example group ID
  ),
  Challenge(
    id: '2',
    title: '21-Day Focus Challenge',
    description: 'Maintain focus for 2 hours daily without phone distractions',
    duration: 21,
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    dailyProgress: [true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
    isCompleted: false,
    badgeName: 'Focus Master',
    type: ChallengeType.daily,
    groupId: 'group1', // Example group ID
  ),
  Challenge(
    id: '3',
    title: 'No Phone Sunday',
    description: 'Keep your phone away for the entire Sunday',
    duration: 1,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    dailyProgress: [true],
    isCompleted: true,
    badgeName: 'Weekend Warrior',
    type: ChallengeType.daily,
    groupId: null, // Not associated with a group
  ),
];

final challengeProvider = StateNotifierProvider<ChallengeNotifier, List<Challenge>>((ref) {
  return ChallengeNotifier();
});

class ChallengeNotifier extends StateNotifier<List<Challenge>> {
  ChallengeNotifier() : super(_mockChallenges);

  void updateChallengeProgress(String challengeId, int dayIndex, bool completed) {
    state = [
      for (final challenge in state)
        if (challenge.id == challengeId)
          challenge.copyWith(
            dailyProgress: [
              for (int i = 0; i < challenge.dailyProgress.length; i++)
                if (i == dayIndex)
                  completed
                else
                  challenge.dailyProgress[i]
            ],
          )
        else
          challenge
    ];
  }

  void addChallenge(Challenge challenge) {
    state = [...state, challenge];
  }

  void removeChallenge(String challengeId) {
    state = state.where((challenge) => challenge.id != challengeId).toList();
  }

  void markTodayComplete(String challengeId) {
    final now = DateTime.now();
    final List<Challenge> newState = [];
    
    for (final challenge in state) {
      if (challenge.id == challengeId) {
        // Calculate the day index based on start date
        final daysSinceStart = now.difference(challenge.startDate).inDays;
        
        // Make sure we don't exceed the challenge duration
        if (daysSinceStart < challenge.duration) {
          // Create a new dailyProgress list with today marked as complete
          final newDailyProgress = List<bool>.from(challenge.dailyProgress);
          
          // Extend the list if necessary
          while (newDailyProgress.length <= daysSinceStart) {
            newDailyProgress.add(false);
          }
          
          // Mark today as complete
          newDailyProgress[daysSinceStart] = true;
          
          // Check if challenge is completed
          final isCompleted = newDailyProgress.where((day) => day).length >= challenge.duration;
          
          newState.add(challenge.copyWith(
            dailyProgress: newDailyProgress,
            isCompleted: isCompleted,
          ));
        } else {
          newState.add(challenge);
        }
      } else {
        newState.add(challenge);
      }
    }
    
    state = newState;
  }

  void updateChallenge(Challenge updatedChallenge) {
    state = [
      for (final challenge in state)
        if (challenge.id == updatedChallenge.id)
          updatedChallenge
        else
          challenge
    ];
  }
}