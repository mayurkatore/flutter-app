import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';
import 'permission_service.dart';
import 'storage_service.dart';
import 'geofence_service.dart';

class LocationService {
  static const String _locationDataKey = 'location_tracking_data';
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StorageService _storageService = StorageService();

  final GeofenceService _geofenceService = GeofenceService();
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  bool _isTracking = false;

  /// Initialize the location service
  Future<bool> init() async {
    Logger.info('Initializing LocationService');

    try {
      // Initialize storage
      await _storageService.init();

      // Initialize geofencing
      await _geofenceService.loadGeofenceData();

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Logger.warning('Location services are disabled');
        return false;
      }

      // Check permissions
      final hasPermission = await PermissionService.hasLocationPermission();
      if (!hasPermission) {
        Logger.warning('Location permission not granted');
        return false;
      }

      Logger.info('LocationService initialized successfully');
      return true;
    } catch (e) {
      Logger.error('Error initializing LocationService: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    Logger.debug('Getting current location');

    try {
      // Check initialization
      final initialized = await init();
      if (!initialized) {
        Logger.warning('LocationService not properly initialized');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentPosition = position;
      Logger.info(
          'Current location obtained: ${position.latitude}, ${position.longitude}');

      // Save location data
      await _saveLocationData(position);

      return position;
    } catch (e) {
      Logger.error('Error getting current location: $e');
      return null;
    }
  }

  /// Start location tracking
  Future<bool> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration timeInterval = const Duration(minutes: 5),
  }) async {
    Logger.info('Starting location tracking');

    try {
      // Check initialization
      final initialized = await init();
      if (!initialized) {
        Logger.warning(
            'Cannot start tracking - LocationService not properly initialized');
        return false;
      }

      if (_isTracking) {
        Logger.warning('Location tracking already active');
        return true;
      }

      final locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: const Duration(seconds: 30),
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          Logger.debug(
              'Location update: ${position.latitude}, ${position.longitude}');
          _saveLocationData(position);
          _analyzeLocationData(position);

          // Check geofences
          final triggeredGeofences = _geofenceService.checkPosition(position);
          if (triggeredGeofences.isNotEmpty) {
            for (final geofence in triggeredGeofences) {
              Logger.info(
                  'Entered geofence: ${geofence['name']} (${geofence['distance'].toStringAsFixed(2)}m)');
            }
          }
        },
        onError: (error) {
          Logger.error('Location tracking error: $error');
        },
      );

      _isTracking = true;
      Logger.info('Location tracking started successfully');
      return true;
    } catch (e) {
      Logger.error('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    Logger.info('Stopping location tracking');

    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _isTracking = false;
      Logger.info('Location tracking stopped successfully');
    } catch (e) {
      Logger.error('Error stopping location tracking: $e');
    }
  }

  /// Check if currently tracking location
  bool get isTracking => _isTracking;

  /// Get current position (cached)
  Position? get currentPosition => _currentPosition;

  /// Calculate distance between two positions
  double calculateDistance(Position start, Position end) {
    final distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    Logger.debug('Distance calculated: ${distance.toStringAsFixed(2)} meters');
    return distance;
  }

  /// Get location history
  Future<List<Map<String, dynamic>>> getLocationHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Logger.debug('Getting location history');

    try {
      final allData = await _getStoredLocationData();

      if (startDate == null && endDate == null) {
        return allData;
      }

      final filteredData = allData.where((location) {
        final timestamp = DateTime.parse(location['timestamp']);

        if (startDate != null && timestamp.isBefore(startDate)) {
          return false;
        }

        if (endDate != null && timestamp.isAfter(endDate)) {
          return false;
        }

        return true;
      }).toList();

      Logger.debug('Filtered location history: ${filteredData.length} entries');
      return filteredData;
    } catch (e) {
      Logger.error('Error getting location history: $e');
      return [];
    }
  }

  /// Get daily movement statistics
  Future<Map<String, dynamic>> getDailyMovementStats([DateTime? date]) async {
    Logger.debug('Getting daily movement statistics');

    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dayData = await getLocationHistory(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      if (dayData.isEmpty) {
        return {
          'totalDistance': 0.0,
          'locations': 0,
          'averageSpeed': 0.0,
          'timeActive': 0,
        };
      }

      double totalDistance = 0.0;
      double totalSpeed = 0.0;
      int speedCount = 0;

      for (int i = 1; i < dayData.length; i++) {
        final prev = dayData[i - 1];
        final curr = dayData[i];

        final prevPos = Position(
          latitude: prev['latitude'],
          longitude: prev['longitude'],
          timestamp: DateTime.parse(prev['timestamp']),
          accuracy: prev['accuracy'],
          altitude: prev['altitude'],
          heading: prev['heading'],
          speed: prev['speed'],
          speedAccuracy: prev['speedAccuracy'],
          altitudeAccuracy: prev['altitudeAccuracy'],
          headingAccuracy: prev['headingAccuracy'],
        );

        final currPos = Position(
          latitude: curr['latitude'],
          longitude: curr['longitude'],
          timestamp: DateTime.parse(curr['timestamp']),
          accuracy: curr['accuracy'],
          altitude: curr['altitude'],
          heading: curr['heading'],
          speed: curr['speed'],
          speedAccuracy: curr['speedAccuracy'],
          altitudeAccuracy: curr['altitudeAccuracy'],
          headingAccuracy: curr['headingAccuracy'],
        );

        final distance = calculateDistance(prevPos, currPos);
        totalDistance += distance;

        if (curr['speed'] != null && curr['speed'] > 0) {
          totalSpeed += curr['speed'];
          speedCount++;
        }
      }

      final stats = {
        'totalDistance': totalDistance,
        'locations': dayData.length,
        'averageSpeed': speedCount > 0 ? totalSpeed / speedCount : 0.0,
        'timeActive': dayData.length * 5, // Assuming 5-minute intervals
      };

      Logger.debug('Daily movement stats: $stats');
      return stats;
    } catch (e) {
      Logger.error('Error getting daily movement stats: $e');
      return {
        'totalDistance': 0.0,
        'locations': 0,
        'averageSpeed': 0.0,
        'timeActive': 0,
      };
    }
  }

  /// Save location data to storage
  Future<void> _saveLocationData(Position position) async {
    try {
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'timestamp': position.timestamp.toIso8601String(),
        'altitudeAccuracy': position.altitudeAccuracy,
        'headingAccuracy': position.headingAccuracy,
      };

      final existingData = await _getStoredLocationData();
      existingData.add(locationData);

      // Keep only last 1000 location points to manage storage
      if (existingData.length > 1000) {
        existingData.removeRange(0, existingData.length - 1000);
      }

      await _storageService.saveLocationData(existingData);

      Logger.debug('Location data saved');
    } catch (e) {
      Logger.error('Error saving location data: $e');
    }
  }

  /// Get stored location data
  Future<List<Map<String, dynamic>>> _getStoredLocationData() async {
    try {
      final data = await _storageService.getData(_locationDataKey);
      if (data == null) return [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Logger.error('Error getting stored location data: $e');
      return [];
    }
  }

  /// Analyze location data for insights
  void _analyzeLocationData(Position position) {
    try {
      // Check geofences
      final triggeredGeofences = _geofenceService.checkPosition(position);
      if (triggeredGeofences.isNotEmpty) {
        for (final geofence in triggeredGeofences) {
          Logger.info(
              'Geofence triggered: ${geofence['name']} (${geofence['distance'].toStringAsFixed(2)}m)');
          // Handle geofence events here (e.g., start focus mode, track time spent in location)
        }
      }

      // Basic movement analysis
      if (position.speed > 1.0) {
        // 1 m/s ≈ 3.6 km/h
        Logger.debug('Movement detected: ${position.speed} m/s');
        // Could trigger "on-the-go" mode or disable certain features
      }
    } catch (e) {
      Logger.error('Error analyzing location data: $e');
    }
  }

  /// Clear all location data
  Future<void> clearLocationData() async {
    Logger.info('Clearing all location data');

    try {
      await _storageService.saveLocationData([]);
      Logger.info('Location data cleared successfully');
    } catch (e) {
      Logger.error('Error clearing location data: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    Logger.info('Disposing LocationService');
    await stopLocationTracking();
  }
}
