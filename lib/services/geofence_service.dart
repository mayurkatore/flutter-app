import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  final StorageService _storageService = StorageService();
  final Map<String, _GeofenceRegion> _activeGeofences = {};
  static const String _geofenceDataKey = 'geofence_data';

  Future<void> addGeofence({
    required String id,
    required double latitude,
    required double longitude,
    required double radius, // in meters
    String? name,
  }) async {
    final geofence = _GeofenceRegion(
      id: id,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      name: name ?? 'Geofence $id',
    );

    _activeGeofences[id] = geofence;
    await _saveGeofenceData();
    Logger.info('Added geofence: ${geofence.name}');
  }

  Future<void> removeGeofence(String id) async {
    _activeGeofences.remove(id);
    await _saveGeofenceData();
    Logger.info('Removed geofence: $id');
  }

  Future<void> _saveGeofenceData() async {
    final geofenceData = _activeGeofences.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _storageService.saveData(_geofenceDataKey, geofenceData);
  }

  Future<void> loadGeofenceData() async {
    final data = await _storageService.getData(_geofenceDataKey);
    if (data != null) {
      _activeGeofences.clear();
      (data as Map).forEach((key, value) {
        _activeGeofences[key.toString()] = _GeofenceRegion.fromJson(
          Map<String, dynamic>.from(value),
        );
      });
    }
  }

  List<Map<String, dynamic>> checkPosition(Position position) {
    final triggeredGeofences = <Map<String, dynamic>>[];

    for (final geofence in _activeGeofences.values) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      if (distance <= geofence.radius) {
        triggeredGeofences.add({
          'id': geofence.id,
          'name': geofence.name,
          'distance': distance,
        });
      }
    }

    return triggeredGeofences;
  }

  List<Map<String, dynamic>> get activeGeofences =>
      _activeGeofences.values.map((geofence) => geofence.toJson()).toList();
}

class _GeofenceRegion {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;

  _GeofenceRegion({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };

  factory _GeofenceRegion.fromJson(Map<String, dynamic> json) {
    return _GeofenceRegion(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }
}
