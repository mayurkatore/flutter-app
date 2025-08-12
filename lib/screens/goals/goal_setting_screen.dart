import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/goal_provider.dart';
import '../../models/goal.dart';

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  Duration _weeklyLimit = const Duration(hours: 0);
  GoalCategory _selectedCategory = GoalCategory.custom;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (minutes == 0) {
      return '$hours hours';
    } else {
      return '$hours hours $minutes minutes';
    }
  }

  void _saveGoal() {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a goal title');
      return;
    }

    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      reason: _reasonController.text,
      weeklyLimit: _weeklyLimit,
      timeSaved: Duration.zero,
      startDate: DateTime.now(),
      isActive: true,
      category: _selectedCategory,
    );

    ref.read(goalProvider.notifier).addGoal(newGoal);

    // Clear form
    _titleController.clear();
    _reasonController.clear();
    setState(() {
      _weeklyLimit = const Duration(hours: 0);
      _selectedCategory = GoalCategory.custom;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal saved successfully!')),
    );

    // Close the dialog
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Setting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddGoalDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your digital wellness goals',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Active Goals Section
            const Text(
              'Your Active Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: goals.isEmpty
                  ? const Center(
                      child: Text('No goals set yet. Create your first goal!'),
                    )
                  : ListView.builder(
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return _buildGoalCard(goal);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
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
                  goal.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: goal.isActive,
                  onChanged: (value) {
                    ref.read(goalProvider.notifier).toggleGoalActive(goal.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              goal.reason,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: goal.progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 5),
            Text(
              '${goal.timeSaved.inHours}h ${goal.timeSaved.inMinutes % 60}m saved',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(goal.category.name),
                  backgroundColor: Colors.blue[100],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Edit goal
                        _showEditGoalDialog(goal);
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete goal
                        _showDeleteConfirmationDialog(goal);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    // Reset form fields
    _titleController.clear();
    _reasonController.clear();
    setState(() {
      _weeklyLimit = const Duration(hours: 0);
      _selectedCategory = GoalCategory.custom;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g., Reduce Social Media Usage',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'e.g., For better sleep',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<GoalCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: GoalCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text('Weekly Limit'),
                Slider(
                  value: _weeklyLimit.inMinutes.toDouble(),
                  min: 0,
                  max: 1200, // 20 hours in minutes
                  divisions: 120, // 10 divisions per hour
                  label: '${_formatDuration(_weeklyLimit)}',
                  onChanged: (value) {
                    setState(() {
                      _weeklyLimit = Duration(minutes: value.toInt());
                    });
                  },
                ),
                Text('${_formatDuration(_weeklyLimit)} per week'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditGoalDialog(Goal goal) {
    // Populate form fields with existing goal data
    _titleController.text = goal.title;
    _reasonController.text = goal.reason;
    setState(() {
      _weeklyLimit = const Duration(hours: 0);
      _selectedCategory = goal.category;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g., Reduce Social Media Usage',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'e.g., For better sleep',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<GoalCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: GoalCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text('Weekly Limit'),
                Slider(
                  value: _weeklyLimit.inMinutes.toDouble(),
                  min: 0,
                  max: 1200, // 20 hours in minutes
                  divisions: 120, // 10 divisions per hour
                  label: '${_formatDuration(_weeklyLimit)}',
                  onChanged: (value) {
                    setState(() {
                      _weeklyLimit = Duration(minutes: value.toInt());
                    });
                  },
                ),
                Text('${_formatDuration(_weeklyLimit)} per week'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the goal by removing the old one and adding the updated one
                ref.read(goalProvider.notifier).removeGoal(goal.id);
                final updatedGoal = Goal(
                  id: goal.id,
                  title: _titleController.text,
                  reason: _reasonController.text,
                  weeklyLimit: _weeklyLimit,
                  timeSaved: goal.timeSaved,
                  startDate: goal.startDate,
                  isActive: goal.isActive,
                  category: _selectedCategory,
                );
                ref.read(goalProvider.notifier).addGoal(updatedGoal);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal updated successfully!')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete the goal
                ref.read(goalProvider.notifier).removeGoal(goal.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal deleted successfully!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}