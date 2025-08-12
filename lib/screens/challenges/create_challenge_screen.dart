import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _badgeNameController = TextEditingController();
  late DateTime _startDate;
  late ChallengeType _challengeType;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _challengeType = ChallengeType.daily;
    _duration = 7; // Default to 7 days
  }

  void _createChallenge() {
    if (_formKey.currentState!.validate()) {
      final newChallenge = Challenge(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        duration: _duration,
        startDate: _startDate,
        dailyProgress: [],
        isCompleted: false,
        badgeName: _badgeNameController.text,
        type: _challengeType,
      );

      ref.read(challengeProvider.notifier).addChallenge(newChallenge);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _badgeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Challenge'),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorScheme.onSurfaceVariant),
            onPressed: _createChallenge,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Challenge Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter challenge title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge title';
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
                    hintText: 'Enter challenge description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Challenge Type
                const Text(
                  'Challenge Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ChallengeType>(
                  value: _challengeType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ChallengeType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _challengeType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Duration
                const Text(
                  'Duration (days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter duration in days',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _duration.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final duration = int.tryParse(value);
                    if (duration != null && duration > 0) {
                      setState(() {
                        _duration = duration;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Start Date
                const Text(
                  'Start Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                        Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Badge Name
                const Text(
                  'Badge Name (Optional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _badgeNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter badge name',
                  ),
                ),
                const SizedBox(height: 20),

                // Create Button
                Center(
                  child: ElevatedButton(
                    onPressed: _createChallenge,
                    child: const Text('Create Challenge'),
                  ),
                ),
                const SizedBox(height: 20), // Add some padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}