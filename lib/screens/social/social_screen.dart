import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'create_group_screen.dart';
import 'add_member_screen.dart';
import 'edit_group_screen.dart';
import '../../providers/group_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/group.dart';
import '../../models/challenge.dart';
import '../challenges/edit_challenge_screen.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              // Navigate to create new group screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join group challenges with friends',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Active Groups Section
            const Text(
              'Your Groups',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (groups.isEmpty)
              const Center(
                child: Text(
                  'No groups yet. Create your first group!',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...groups
                  .map((group) => _buildGroupCard(
                        context,
                        ref,
                        group: group,
                        onAddMember: () {
                          // Navigate to add member screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddMemberScreen(group: group)),
                          );
                        },
                      ))
                  .toList(),
            const SizedBox(height: 30),

            // Available Challenges Section
            const Text(
              'Join a Challenge',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildChallengeCard(
              context,
              title: 'Weekend Warrior Challenge',
              description: 'Keep your phone away during weekend hours',
              participantCount: 24,
              startDate: DateTime.now().add(const Duration(days: 2)),
            ),
            const SizedBox(height: 10),
            _buildChallengeCard(
              context,
              title: 'Early Bird Challenge',
              description: 'Wake up before 7 AM for 7 consecutive days',
              participantCount: 42,
              startDate: DateTime.now().add(const Duration(days: 1)),
            ),
            const SizedBox(height: 30),

            // Leaderboard Section
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLeaderboardEntry(
              context,
              rank: 1,
              name: 'Alex Johnson',
              points: 1250,
              isCurrentUser: false,
            ),
            _buildLeaderboardEntry(
              context,
              rank: 2,
              name: 'You',
              points: 1180,
              isCurrentUser: true,
            ),
            _buildLeaderboardEntry(
              context,
              rank: 3,
              name: 'Sam Wilson',
              points: 1120,
              isCurrentUser: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    WidgetRef ref, {
    required Group group,
    VoidCallback? onAddMember,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get challenges associated with this group
    final challenges = ref.watch(challengeProvider);
    final groupChallenges =
        challenges.where((challenge) => challenge.groupId == group.id).toList();

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
                  group.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('${group.members.length} members'),
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              group.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Display group challenges
            if (groupChallenges.isNotEmpty) ...[
              const Text(
                'Group Challenges',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...groupChallenges
                  .map((challenge) => _buildChallengeItem(
                        context,
                        ref,
                        challenge: challenge,
                        group: group,
                      ))
                  .toList(),
              const SizedBox(height: 10),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View group details')),
                    );
                  },
                  child: const Text('View Details'),
                ),
                Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
                      onPressed: () {
                        // Edit group functionality
                        _editGroup(context, ref, group);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () {
                        // Delete group functionality with confirmation
                        _deleteGroup(context, ref, group);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add,
                          color: colorScheme.onSurfaceVariant),
                      onPressed: onAddMember,
                    ),
                    IconButton(
                      icon: Icon(Icons.share,
                          color: colorScheme.onSurfaceVariant),
                      onPressed: () {
                        _shareGroup(context, group);
                      },
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

  Widget _buildChallengeCard(
    BuildContext context, {
    required String title,
    required String description,
    required int participantCount,
    required DateTime startDate,
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
              children: [
                Icon(Icons.people,
                    size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text('$participantCount participants'),
                const SizedBox(width: 20),
                Icon(Icons.calendar_today,
                    size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  '${startDate.day}/${startDate.month}/${startDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join challenge')),
                );
              },
              child: const Text('Join Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    BuildContext context, {
    required int rank,
    required String name,
    required int points,
    required bool isCurrentUser,
  }) {
    return Card(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight:
                      isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text('$points pts'),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold color
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  void _editGroup(BuildContext context, WidgetRef ref, Group group) {
    // Navigate to edit group screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupScreen(group: group),
      ),
    );
  }

  void _deleteGroup(BuildContext context, WidgetRef ref, Group group) async {
    // Show a confirmation dialog before deleting
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text(
              'Are you sure you want to delete the group "${group.name}"? This action cannot be undone.'),
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

    // If user confirmed deletion, proceed with deleting the group
    if (confirmDelete == true) {
      ref.read(groupProvider.notifier).deleteGroup(group.id);

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted')),
      );
    }
  }

  Widget _buildChallengeItem(
    BuildContext context,
    WidgetRef ref, {
    required Challenge challenge,
    required Group group,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = challenge.progressPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          size: 18, color: colorScheme.onSurfaceVariant),
                      onPressed: () {
                        _editChallenge(context, ref, challenge, group);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          size: 18, color: colorScheme.error),
                      onPressed: () {
                        _deleteChallenge(context, ref, challenge, group);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              challenge.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.onSurfaceVariant.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 5),
            Text(
              '${(progress * 100).round()}% complete',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _editChallenge(
      BuildContext context, WidgetRef ref, Challenge challenge, Group group) {
    // Navigate to edit challenge screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditChallengeScreen(challenge: challenge),
      ),
    );
  }

  void _deleteChallenge(BuildContext context, WidgetRef ref,
      Challenge challenge, Group group) async {
    // Show a confirmation dialog before deleting
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Challenge'),
          content: Text(
              'Are you sure you want to delete the challenge "${challenge.title}"? This action cannot be undone.'),
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

    // If user confirmed deletion, proceed with deleting the challenge
    if (confirmDelete == true) {
      ref.read(challengeProvider.notifier).removeChallenge(challenge.id);

      // Also remove the challenge from the group
      ref
          .read(groupProvider.notifier)
          .removeChallengeFromGroup(group.id, challenge.id);

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge deleted')),
      );
    }
  }

  void _shareGroup(BuildContext context, Group group) {
    // Show a bottom sheet with sharing options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share Group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Invite others to join your group'),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.link,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Copy Invite Link'),
                onTap: () {
                  Navigator.pop(context);
                  _copyInviteLink(context, group);
                },
              ),
              ListTile(
                leading: Icon(Icons.email,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Send Email Invite'),
                onTap: () {
                  Navigator.pop(context);
                  _sendEmailInvite(context, group);
                },
              ),
              ListTile(
                leading: Icon(Icons.message,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Send Message Invite'),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessageInvite(context, group);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyInviteLink(BuildContext context, Group group) {
    // In a real app, this would generate an actual invite link
    final inviteLink = 'https://app.example.com/invite/${group.id}';

    // Show a snackbar with the invite link
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite link copied: $inviteLink'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _sendEmailInvite(BuildContext context, Group group) {
    // In a real app, this would open the email app with a pre-filled message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Email invite functionality to be implemented')),
    );
  }

  void _sendMessageInvite(BuildContext context, Group group) {
    // In a real app, this would open the messaging app with a pre-filled message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Message invite functionality to be implemented')),
    );
  }
}
