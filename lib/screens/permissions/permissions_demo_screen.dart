import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import '../../models/app_usage_info.dart';
import '../../providers/screen_time_provider.dart';
import '../../services/screen_time_service.dart';

// Helper function to format duration into a readable string like HH:mm:ss
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

class PermissionsDemoScreen extends ConsumerWidget {
  const PermissionsDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenTimeState = ref.watch(screenTimeTrackingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(screenTimeTrackingProvider),
          ),
        ],
      ),
      body: Center(
        child: screenTimeState.when(
          data: (data) {
            if (!data.hasPermission) {
              // Pass the service instance to the permission UI
              return _buildPermissionRequestUI(context, ref, ScreenTimeService());
            }
            if (data.appUsage.isEmpty) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Screen time permission is granted.'),
                  SizedBox(height: 16),
                  Text('No screen time data available for today.'),
                ],
              );
            }
            return _buildScreenTimeList(context, data);
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${error.toString()}',
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(screenTimeTrackingProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequestUI(BuildContext context, WidgetRef ref, ScreenTimeService service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Usage permission is required to see screen time data.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await service.requestUsagePermission();
              ref.invalidate(screenTimeTrackingProvider);
            },
            child: const Text('Request Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeList(BuildContext context, ScreenTimeTrackingState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Screen Time Today: ${_formatDuration(state.totalScreenTime)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.appUsage.length,
            itemBuilder: (context, index) {
              final AppUsageInfo app = state.appUsage[index];
              return ListTile(

                title: Text(app.appName),
                trailing: Text(_formatDuration(app.usage)),
              );
            },
          ),
        ),
      ],
    );
  }
}
