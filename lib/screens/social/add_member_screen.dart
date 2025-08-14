import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final Group group;

  const AddMemberScreen({super.key, required this.group});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  late List<String> _members;
  String _newMember = '';

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.group.members);
  }

  void _addMember() {
    if (_newMember.isNotEmpty && !_members.contains(_newMember)) {
      setState(() {
        _members.add(_newMember);
      });
    }
    _newMember = '';
  }

  void _removeMember(String member) {
    setState(() {
      _members.remove(member);
    });
  }

  void _saveMembers() {
    if (_formKey.currentState!.validate()) {
      // Update the group with new members
      ref.read(groupProvider.notifier).updateGroup(
        widget.group.id,
        widget.group.name,
        widget.group.description,
        _members,
        widget.group.challengeIds,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Members added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorScheme.onSurfaceVariant),
            onPressed: _saveMembers,
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
              // Username
              const Text(
                'Username or Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter username or email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username or email';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _addMember(),
              ),
              const SizedBox(height: 20),

              // Add Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addMember,
                      child: const Text('Add Member'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Members List
              const Text(
                'Members to Add',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                children: _members.map((member) {
                  return Chip(
                    label: Text(member),
                    backgroundColor: colorScheme.primary.withAlpha(26),
                    onDeleted: () => _removeMember(member),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveMembers,
                  child: const Text('Save Members'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}