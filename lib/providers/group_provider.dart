import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Provider for managing groups
final groupProvider = StateNotifierProvider<GroupNotifier, List<Group>>((ref) {
  return GroupNotifier();
});

class GroupNotifier extends StateNotifier<List<Group>> {
  GroupNotifier() : super([]) {
    _loadGroups();
  }

  // Load groups from shared preferences
  Future<void> _loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getString('groups') ?? '[]';
      final List<dynamic> groupsData = json.decode(groupsJson);
      
      state = groupsData.map((e) => Group.fromMap(e)).toList();
    } catch (e) {
      // If there's an error loading, start with an empty list
      state = [];
    }
  }

  // Save groups to shared preferences
  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = json.encode(state.map((e) => e.toMap()).toList());
      await prefs.setString('groups', groupsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Create a new group
  Future<void> createGroup(String name, String description, List<String> members) async {
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      members: members,
      challengeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    state = [...state, newGroup];
    await _saveGroups();
  }

  // Update an existing group
  Future<void> updateGroup(String id, String name, String description, List<String> members, List<String> challengeIds) async {
    state = [
      for (final group in state)
        if (group.id == id)
          group.copyWith(
            name: name,
            description: description,
            members: members,
            challengeIds: challengeIds,
            updatedAt: DateTime.now(),
          )
        else
          group
    ];
    await _saveGroups();
  }

  // Delete a group
  Future<void> deleteGroup(String id) async {
    state = state.where((group) => group.id != id).toList();
    await _saveGroups();
  }

  // Add a member to a group
  Future<void> addMemberToGroup(String groupId, String member) async {
    state = [
      for (final group in state)
        if (group.id == groupId)
          group.copyWith(
            members: [...group.members, member],
            updatedAt: DateTime.now(),
          )
        else
          group
    ];
    await _saveGroups();
  }

  // Add a challenge to a group
  Future<void> addChallengeToGroup(String groupId, String challengeId) async {
    state = [
      for (final group in state)
        if (group.id == groupId)
          group.copyWith(
            challengeIds: [...group.challengeIds, challengeId],
            updatedAt: DateTime.now(),
          )
        else
          group
    ];
    await _saveGroups();
  }

  // Remove a challenge from a group
  Future<void> removeChallengeFromGroup(String groupId, String challengeId) async {
    state = [
      for (final group in state)
        if (group.id == groupId)
          group.copyWith(
            challengeIds: group.challengeIds.where((id) => id != challengeId).toList(),
            updatedAt: DateTime.now(),
          )
        else
          group
    ];
    await _saveGroups();
  }

  // Remove a member from a group
  Future<void> removeMemberFromGroup(String groupId, String member) async {
    state = [
      for (final group in state)
        if (group.id == groupId)
          group.copyWith(
            members: group.members.where((m) => m != member).toList(),
            updatedAt: DateTime.now(),
          )
        else
          group
    ];
    await _saveGroups();
  }
}