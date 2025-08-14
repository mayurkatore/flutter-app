import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/screen_time_service.dart';
import '../../models/app_usage_info.dart';

class ScreenTimePage extends ConsumerStatefulWidget {
  const ScreenTimePage({super.key});

  @override
  ConsumerState<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends ConsumerState<ScreenTimePage> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  String _totalTime = "Loading...";
  List<AppUsageInfo> _appsUsage = [];
  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    _fetchUsage();
  }

  Future<void> _fetchUsage() async {
    // Check permission
    bool granted = await _screenTimeService.requestUsagePermission();
    if (!granted) {
      if (!_permissionRequested) {
        // Show a dialog explaining that permission is needed
        _showPermissionDialog();
      }
      setState(() {
        _totalTime = "Permission required";
        _appsUsage = [];
      });
      return;
    }

    // Reset permission requested flag if we got permission
    _permissionRequested = false;

    // Get total screen time
    Duration totalDuration = await _screenTimeService.getTotalScreenTime();
    String totalTime = _screenTimeService.formatDuration(totalDuration);

    // Get app usage stats
    List<AppUsageInfo> usageStats = await _screenTimeService.getTodayAppUsage();

    // Sort by usage time (descending)
    usageStats.sort((a, b) => b.usage.compareTo(a.usage));

    setState(() {
      _totalTime = totalTime;
      _appsUsage = usageStats;
    });
  }

  void _showPermissionDialog() {
    _permissionRequested = true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Screen Time Permission Required"),
          content: const Text(
            "This app needs permission to access your screen time data. "
            "Please enable 'Usage Access' in your device settings for this app.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Try to get permission again
                _fetchUsage();
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Time"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsage,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total screen time card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Screen Time",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _totalTime,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Apps usage list
              const Text(
                "App Usage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              if (_appsUsage.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No app usage data available",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchUsage,
                    child: ListView.builder(
                      itemCount: _appsUsage.length,
                      itemBuilder: (context, index) {
                        var app = _appsUsage[index];
                        return Card(
                          child: ListTile(
                            title: Text(app.appName),
                            subtitle: Text(
                              "Usage: ${_screenTimeService.formatDuration(app.usage)}",
                            ),
                            trailing: _screenTimeService.appLimits.containsKey(app.packageName)
                                ? Icon(
                                    Icons.block,
                                    color: colorScheme.error,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}