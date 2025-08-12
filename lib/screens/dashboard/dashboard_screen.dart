import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/app_usage_provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/app_usage.dart';
import '../../models/goal.dart';
import '../../services/permission_service.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUsage = ref.watch(appUsageProvider);
    final goals = ref.watch(goalProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Check for usage access permission
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool hasPermission = await PermissionService.checkUsageAccessPermission();
      if (!hasPermission) {
        bool granted = await PermissionService.requestUsageAccessPermission(context);
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usage access permission is required for screen time tracking.')),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Summary Card
              _buildDailySummaryCard(context, appUsage),
              const SizedBox(height: 20),
              
              // Goals Section
              const Text(
                'Your Goals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildGoalsList(goals, context),
              const SizedBox(height: 20),
              
              // App Usage Section
              const Text(
                'App Usage Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildAppUsageList(appUsage, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, List<AppUsage> appUsage) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calculate total usage time
    Duration totalUsage = Duration.zero;
    for (var app in appUsage) {
      totalUsage += app.todayUsage;
    }
    
    // Calculate average usage (assuming 8 hours awake time)
    double usagePercentage = (totalUsage.inMinutes / (8 * 60)).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: usagePercentage,
              center: Text(
                '${totalUsage.inHours}h ${totalUsage.inMinutes % 60}m',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              progressColor: usagePercentage > 0.7 ? Colors.red : colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'You\'ve used your phone for ${totalUsage.inHours} hours and ${totalUsage.inMinutes % 60} minutes today.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (goals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No goals set yet. Create your first goal!'),
        ),
      );
    }

    return Column(
      children: goals.map((goal) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text('Reason: ${goal.reason}'),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  percent: goal.progressPercentage,
                  lineHeight: 10.0,
                  progressColor: goal.progressPercentage > 0.7 ? Colors.green : colorScheme.primary,
                ),
                const SizedBox(height: 5),
                Text(
                  '${goal.timeSaved.inHours}h ${goal.timeSaved.inMinutes % 60}m saved',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppUsageList(List<AppUsage> appUsage, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (appUsage.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No app usage data available.'),
        ),
      );
    }

    // Sort by usage time (highest first)
    final sortedApps = List.from(appUsage)..sort((a, b) => b.todayUsage.compareTo(a.todayUsage));

    return Column(
      children: sortedApps.map((app) {
        final usagePercentage = app.dailyLimit.inMinutes > 0 
            ? (app.todayUsage.inMinutes / app.dailyLimit.inMinutes).clamp(0.0, 1.0)
            : 0.0;
            
        bool isOverLimit = usagePercentage >= 1.0;

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
                      app.appName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (app.isBlocked)
                      const Chip(
                        label: Text('Blocked'),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${app.todayUsage.inHours}h ${app.todayUsage.inMinutes % 60}m today',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                LinearPercentIndicator(
                  percent: usagePercentage,
                  lineHeight: 8.0,
                  progressColor: isOverLimit ? Colors.red : colorScheme.primary,
                ),
                const SizedBox(height: 5),
                Text(
                  'Daily limit: ${app.dailyLimit.inHours}h ${app.dailyLimit.inMinutes % 60}m',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (isOverLimit)
                  const Text(
                    '⚠️ Daily limit exceeded!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}