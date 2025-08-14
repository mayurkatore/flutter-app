import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _members = [];
  String _newMember = '';

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

  void _createGroup() {
    if (_formKey.currentState!.validate()) {
      // Create a new group using the provider
      ref.read(groupProvider.notifier).createGroup(
        _groupNameController.text,
        _descriptionController.text,
        _members,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorScheme.onSurfaceVariant),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Name
              const Text(
                'Group Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter group name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter group description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              
              // Members
              const Text(
                'Add Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter username or email',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _newMember = value;
                        });
                      },
                      onFieldSubmitted: (_) => _addMember(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: colorScheme.primary),
                    onPressed: _addMember,
                  ),
                ],
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
              
              // Create Button
              Center(
                child: ElevatedButton(
                  onPressed: _createGroup,
                  child: const Text('Create Group'),
                ),
              ),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }
}