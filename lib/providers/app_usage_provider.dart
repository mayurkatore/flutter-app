import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_usage.dart';
import '../services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock data for app usage
final List<AppUsage> _mockAppUsage = [
  AppUsage(
    id: '1',
    appName: 'Social Media App',
    packageName: 'com.social.media',
    todayUsage: const Duration(hours: 2, minutes: 30),
    weeklyUsage: const Duration(hours: 15, minutes: 45),
    dailyLimit: const Duration(hours: 1),
    isBlocked: false,
    lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  AppUsage(
    id: '2',
    appName: 'Video Streaming',
    packageName: 'com.video.streaming',
    todayUsage: const Duration(hours: 1, minutes: 15),
    weeklyUsage: const Duration(hours: 8, minutes: 30),
    dailyLimit: const Duration(hours: 2),
    isBlocked: false,
    lastUsed: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  AppUsage(
    id: '3',
    appName: 'Games',
    packageName: 'com.games.app',
    todayUsage: const Duration(hours: 0, minutes: 45),
    weeklyUsage: const Duration(hours: 5, minutes: 20),
    dailyLimit: const Duration(hours: 1),
    isBlocked: true,
    lastUsed: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

final appUsageProvider = StateNotifierProvider<AppUsageNotifier, List<AppUsage>>((ref) {
  return AppUsageNotifier();
});

class AppUsageNotifier extends StateNotifier<List<AppUsage>> {
  AppUsageNotifier() : super(_mockAppUsage);

  void toggleAppBlock(String appId) {
    state = [
      for (final app in state)
        if (app.id == appId)
          app.copyWith(isBlocked: !app.isBlocked)
        else
          app
    ];
    
    // Save the updated state to storage
    _saveToStorage();
  }

  void updateDailyLimit(String appId, Duration newLimit) {
    state = [
      for (final app in state)
        if (app.id == appId)
          app.copyWith(dailyLimit: newLimit)
        else
          app
    ];
    
    // Save the updated state to storage
    _saveToStorage();
  }
  
  void _saveToStorage() async {
    // Convert the state to a list of maps
    final List<Map<String, dynamic>> data = state.map((app) => app.toMap()).toList();
    
    // Save to storage
    final storageService = StorageService();
    await storageService.init();
    await storageService.saveAppUsageData(data);
  }
  
  Future<void> loadFromStorage() async {
    final storageService = StorageService();
    await storageService.init();
    final data = await storageService.getAppUsageData();
    
    // Convert the list of maps to a list of AppUsage objects
    final appUsageList = data.map((map) => AppUsage.fromMap(map)).toList();
    
    // Update the state
    state = appUsageList;
  }
}