import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../models/app_usage_info.dart';
import '../../services/geofence_service.dart';
import '../../utils/logger.dart';

class TestingScreen extends ConsumerStatefulWidget {
  const TestingScreen({super.key});

  @override
  ConsumerState<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends ConsumerState<TestingScreen> {
  final _geofenceService = GeofenceService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize location tracking
      await ref.read(locationTrackingProvider.notifier).initialize();

      // Initialize screen time tracking
      await ref.read(screenTimeTrackingProvider.notifier).initialize();

      // Add test geofence (office location example)
      await _geofenceService.addGeofence(
        id: 'office',
        name: 'Office',
        latitude: 40.7128, // Replace with actual coordinates
        longitude: -74.0060,
        radius: 100, // meters
      );
    } catch (e) {
      Logger.error('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationTrackingProvider);
    final screenTimeState = ref.watch(screenTimeTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationSection(locationState),
            const Divider(height: 32),
            screenTimeState.when(
              data: (state) => _buildScreenTimeSection(state),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(LocationTrackingState locationState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Tracking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status indicators
            Row(
              children: [
                Icon(
                  locationState.hasPermission
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      locationState.hasPermission ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                    'Permission: ${locationState.hasPermission ? 'Granted' : 'Denied'}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  locationState.isTracking
                      ? Icons.location_on
                      : Icons.location_off,
                  color: locationState.isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                    'Tracking: ${locationState.isTracking ? 'Active' : 'Inactive'}'),
              ],
            ),

            if (locationState.currentPosition != null) ...[
              const SizedBox(height: 8),
              Text(
                'Current Location:\nLat: ${locationState.currentPosition!.latitude}\nLng: ${locationState.currentPosition!.longitude}',
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: locationState.hasPermission
                      ? () => ref
                          .read(locationTrackingProvider.notifier)
                          .getCurrentPosition()
                      : null,
                  child: const Text('Get Location'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: locationState.hasPermission
                      ? locationState.isTracking
                          ? () => ref
                              .read(locationTrackingProvider.notifier)
                              .stopTracking()
                          : () => ref
                              .read(locationTrackingProvider.notifier)
                              .startTracking()
                      : null,
                  child: Text(locationState.isTracking
                      ? 'Stop Tracking'
                      : 'Start Tracking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeSection(ScreenTimeTrackingState screenTimeState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screen Time Tracking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status indicators
            Row(
              children: [
                Icon(
                  screenTimeState.hasPermission
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      screenTimeState.hasPermission ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                    'Permission: ${screenTimeState.hasPermission ? 'Granted' : 'Denied'}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  screenTimeState.isTracking
                      ? Icons.phone_android
                      : Icons.phone_android_outlined,
                  color:
                      screenTimeState.isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                    'Tracking: ${screenTimeState.isTracking ? 'Active' : 'Inactive'}'),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Total Screen Time: ${_formatDuration(screenTimeState.totalScreenTime)}',
            ),
            Text('Apps tracked: ${screenTimeState.appUsage.length}'),

            if (screenTimeState.exceededApps.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Apps over limit: ${screenTimeState.exceededApps.length}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: screenTimeState.hasPermission
                      ? () => ref
                          .read(screenTimeTrackingProvider.notifier)
                          .refreshData()
                      : null,
                  child: const Text('Refresh Data'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: screenTimeState.hasPermission
                      ? screenTimeState.isTracking
                          ? () => ref
                              .read(screenTimeTrackingProvider.notifier)
                              .stopTracking()
                          : () => ref
                              .read(screenTimeTrackingProvider.notifier)
                              .startTracking()
                      : null,
                  child: Text(screenTimeState.isTracking
                      ? 'Stop Tracking'
                      : 'Start Tracking'),
                ),
              ],
            ),

            // App usage list
            if (screenTimeState.appUsage.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Top Apps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...screenTimeState.appUsage.take(5).map((app) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.appName),
                              Text(
                                app.packageName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(_formatDuration(app.usage)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}
