import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  final Group group;

  const EditGroupScreen({super.key, required this.group});

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _groupNameController;
  late final TextEditingController _descriptionController;
  late List<String> _members;
  String _newMember = '';

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(text: widget.group.description);
    _members = List.from(widget.group.members);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _saveGroup() {
    if (_formKey.currentState!.validate()) {
      // Update the group using the provider
      ref.read(groupProvider.notifier).updateGroup(
        widget.group.id,
        _groupNameController.text,
        _descriptionController.text,
        _members,
        widget.group.challengeIds,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorScheme.onSurfaceVariant),
            onPressed: _saveGroup,
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
                'Members',
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
              
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveGroup,
                  child: const Text('Save Changes'),
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