import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current position provider
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Location tracking state provider
final locationTrackingProvider = StateNotifierProvider<LocationTrackingNotifier, LocationTrackingState>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return LocationTrackingNotifier(locationService);
});

// Location tracking state class
class LocationTrackingState {
  final bool isTracking;
  final Position? currentPosition;
  final String? error;
  final bool hasPermission;

  const LocationTrackingState({
    this.isTracking = false,
    this.currentPosition,
    this.error,
    this.hasPermission = false,
  });

  LocationTrackingState copyWith({
    bool? isTracking,
    Position? currentPosition,
    String? error,
    bool? hasPermission,
  }) {
    return LocationTrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentPosition: currentPosition ?? this.currentPosition,
      error: error ?? this.error,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

// Location tracking notifier
class LocationTrackingNotifier extends StateNotifier<LocationTrackingState> {
  final LocationService _locationService;

  LocationTrackingNotifier(this._locationService) : super(const LocationTrackingState());

  /// Initialize location service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing location tracking');
      final initialized = await _locationService.init();
      
      state = state.copyWith(
        hasPermission: initialized,
        error: initialized ? null : 'Failed to initialize location service',
      );
      
      if (initialized) {
        // Get current position
        await getCurrentPosition();
      }
    } catch (e) {
      Logger.error('Error initializing location tracking: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get current position
  Future<void> getCurrentPosition() async {
    try {
      Logger.debug('Getting current position');
      final position = await _locationService.getCurrentLocation();
      
      state = state.copyWith(
        currentPosition: position,
        error: position == null ? 'Failed to get location' : null,
      );
    } catch (e) {
      Logger.error('Error getting current position: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Start location tracking
  Future<void> startTracking() async {
    try {
      Logger.info('Starting location tracking');
      final success = await _locationService.startLocationTracking();
      
      state = state.copyWith(
        isTracking: success,
        error: success ? null : 'Failed to start location tracking',
      );
    } catch (e) {
      Logger.error('Error starting location tracking: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    try {
      Logger.info('Stopping location tracking');
      await _locationService.stopLocationTracking();
      
      state = state.copyWith(isTracking: false);
    } catch (e) {
      Logger.error('Error stopping location tracking: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Daily movement stats provider
final dailyMovementStatsProvider = FutureProvider.family<Map<String, dynamic>, DateTime?>((ref, date) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getDailyMovementStats(date);
});

// Location history provider
final locationHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, LocationHistoryParams>((ref, params) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getLocationHistory(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Location history parameters class
class LocationHistoryParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const LocationHistoryParams({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationHistoryParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}