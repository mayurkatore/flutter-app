import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';

// Mock data for goals
final List<Goal> _mockGoals = [
  Goal(
    id: '1',
    title: 'Reduce Social Media Usage',
    reason: 'health',
    weeklyLimit: const Duration(hours: 5),
    timeSaved: const Duration(hours: 3, minutes: 30),
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    isActive: true,
    category: GoalCategory.socialMedia,
  ),
  Goal(
    id: '2',
    title: 'Focus on Studies',
    reason: 'study',
    weeklyLimit: const Duration(hours: 10),
    timeSaved: const Duration(hours: 8, minutes: 15),
    startDate: DateTime.now().subtract(const Duration(days: 14)),
    isActive: true,
    category: GoalCategory.productivity,
  ),
  Goal(
    id: '3',
    title: 'Better Sleep Schedule',
    reason: 'sleep',
    weeklyLimit: const Duration(hours: 2),
    timeSaved: const Duration(hours: 1, minutes: 45),
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    isActive: true,
    category: GoalCategory.custom,
  ),
];

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super(_mockGoals);

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void updateGoal(Goal updatedGoal) {
    state = [
      for (final goal in state)
        if (goal.id == updatedGoal.id) updatedGoal else goal
    ];
  }

  void removeGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
  }

  void toggleGoalActive(String id) {
    state = [
      for (final goal in state)
        if (goal.id == id) goal.copyWith(isActive: !goal.isActive) else goal
    ];
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});