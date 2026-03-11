import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/live_location_model.dart';
import '../models/bus_model.dart';

class TrackingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Map<String, Timer> _activeTimers = {};
  final Map<String, LiveLocationModel> _cache = {};

  // ========================================
  // DEMO MODE: PHONE GPS METHODS (DRIVER ONLY)
  // ========================================

  /// Check and request location permissions
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) debugPrint('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Get current phone GPS location and WRITE to Firebase (Driver only)
  Future<LiveLocationModel?> _getPhoneLocationAndSave(String busId) async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        if (kDebugMode) debugPrint('Location permission denied for bus $busId');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final location = LiveLocationModel(
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        ignition: position.speed > AppConfig.minimumSpeedForMoving,
        lastUpdated: DateTime.now(),
        deviceId: 'PHONE_GPS',
      );

      // Cache in memory
      _cache[busId] = location;

      // WRITE to Firebase so admin/student can read it
      await _saveToCacheDB(location);

      if (kDebugMode) {
        debugPrint('📍 DRIVER GPS written: Bus $busId at ${position.latitude}, ${position.longitude}');
      }

      return location;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting phone location for bus $busId: $e');

      if (_cache.containsKey(busId)) return _cache[busId];
      return await _getFromCacheDB(busId);
    }
  }

  /// Stream phone GPS and continuously WRITE to Firebase (Driver only)
  Stream<LiveLocationModel?> _getPhoneLocationStream(String busId) async* {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      yield null;
      return;
    }

    // Initial position
    final initialLocation = await _getPhoneLocationAndSave(busId);
    yield initialLocation;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    await for (final Position position in Geolocator.getPositionStream(
      locationSettings: locationSettings,
    )) {
      final location = LiveLocationModel(
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        ignition: position.speed > AppConfig.minimumSpeedForMoving,
        lastUpdated: DateTime.now(),
        deviceId: 'PHONE_GPS',
      );

      // Cache and WRITE to Firebase
      _cache[busId] = location;
      await _saveToCacheDB(location);

      if (kDebugMode) {
        debugPrint('📍 DRIVER GPS update: Bus $busId at ${position.latitude}, ${position.longitude}');
      }

      yield location;
    }
  }

  // ========================================
  // PRODUCTION MODE: WHEELSEYE API METHODS
  // ========================================

  Future<LiveLocationModel?> _getWheelsEyeLocation(
      String deviceId,
      String busId,
      ) async {
    try {
      final url = AppConfig.getTrackingUrl(deviceId);
      final uri = Uri.parse(url);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${AppConfig.wheelsEyeApiKey}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final location = LiveLocationModel(
          busId: busId,
          latitude: _parseDouble(data['latitude'] ?? data['lat']),
          longitude: _parseDouble(data['longitude'] ?? data['lng'] ?? data['lon']),
          speed: _parseDouble(data['speed']),
          ignition: data['ignition'] as bool? ?? data['engine'] as bool?,
          lastUpdated: data['timestamp'] != null
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
          deviceId: deviceId,
        );

        _cache[busId] = location;
        await _saveToCacheDB(location);

        return location;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching WheelsEye location for device $deviceId: $e');
      if (_cache.containsKey(busId)) return _cache[busId];
      return await _getFromCacheDB(busId);
    }
  }

  // ========================================
  // UNIFIED PUBLIC API
  // ========================================

  /// Fetch location.
  /// - isDriver=true  → get device GPS and WRITE to Firebase (driver's own phone)
  /// - isDriver=false → READ from Firebase live_cache (admin/student)
  Future<LiveLocationModel?> fetchLocation(BusModel bus, {bool isDriver = false}) async {
    if (AppConfig.USE_DEMO_MODE) {
      if (isDriver) {
        // Driver: use this device's GPS and write to Firebase
        if (kDebugMode) debugPrint('🚌 DRIVER: Writing GPS for bus ${bus.busId}');
        return await _getPhoneLocationAndSave(bus.busId);
      } else {
        // Admin/Student: READ from Firebase where driver wrote their location
        if (kDebugMode) debugPrint('👁 OBSERVER: Reading Firebase cache for bus ${bus.busId}');
        return await _getFromCacheDB(bus.busId);
      }
    } else {
      // Production Mode: WheelsEye API
      if (!bus.hasTracker) {
        if (kDebugMode) debugPrint('Bus ${bus.busId} has no tracker device configured');
        return null;
      }
      return await _getWheelsEyeLocation(bus.trackerDeviceId!, bus.busId);
    }
  }

  /// Stream location updates.
  /// - isDriver=true  → stream device GPS and continuously write to Firebase
  /// - isDriver=false → stream from Firebase live_cache (real-time listener)
  Stream<LiveLocationModel?> trackBus(BusModel bus, {bool isDriver = false}) async* {
    if (AppConfig.USE_DEMO_MODE) {
      if (isDriver) {
        // Driver: stream this device's GPS, writing each update to Firebase
        if (kDebugMode) debugPrint('🚌 DRIVER: Streaming GPS for bus ${bus.busId}');
        yield* _getPhoneLocationStream(bus.busId);
      } else {
        // Admin/Student: stream real-time from Firebase live_cache
        if (kDebugMode) debugPrint('👁 OBSERVER: Streaming Firebase cache for bus ${bus.busId}');
        yield* streamCachedLocation(bus.busId);
      }
    } else {
      // Production Mode: WheelsEye API
      if (!bus.hasTracker) {
        yield null;
        return;
      }

      final initialLocation = await _getWheelsEyeLocation(
        bus.trackerDeviceId!,
        bus.busId,
      );
      yield initialLocation;

      yield* Stream.periodic(
        Duration(seconds: AppConfig.locationUpdateInterval),
            (_) async {
          return await _getWheelsEyeLocation(bus.trackerDeviceId!, bus.busId);
        },
      ).asyncMap((future) => future);
    }
  }

  /// Start background tracking timers.
  /// Only drivers should call this with isDriver=true.
  void startTrackingBuses(List<BusModel> buses, {bool isDriver = false}) {
    for (var bus in buses) {
      final shouldTrack = AppConfig.USE_DEMO_MODE
          ? (bus.driverId != null && bus.driverId!.isNotEmpty)
          : bus.hasTracker;

      if (shouldTrack && !_activeTimers.containsKey(bus.busId)) {
        final interval = AppConfig.USE_DEMO_MODE
            ? AppConfig.demoLocationUpdateInterval
            : AppConfig.locationUpdateInterval;

        _activeTimers[bus.busId] = Timer.periodic(
          Duration(seconds: interval),
              (_) async {
            await fetchLocation(bus, isDriver: isDriver);
          },
        );
      }
    }
  }

  /// Stop tracking a specific bus
  void stopTrackingBus(String busId) {
    if (_activeTimers.containsKey(busId)) {
      _activeTimers[busId]!.cancel();
      _activeTimers.remove(busId);
    }
  }

  /// Stop all tracking
  void stopAllTracking() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _cache.clear();
  }

  /// Get cached location (synchronous)
  LiveLocationModel? getCachedLocation(String busId) {
    return _cache[busId];
  }

  /// Stream from Firebase live_cache (real-time listener)
  Stream<LiveLocationModel?> streamCachedLocation(String busId) {
    return _database.child('live_cache/$busId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return LiveLocationModel.fromJson(data, busId);
      }
      return null;
    });
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _saveToCacheDB(LiveLocationModel location) async {
    try {
      await _database.child('live_cache/${location.busId}').set(location.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving to cache DB: $e');
    }
  }

  Future<LiveLocationModel?> _getFromCacheDB(String busId) async {
    try {
      final snapshot = await _database.child('live_cache/$busId').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return LiveLocationModel.fromJson(data, busId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error reading from cache DB: $e');
    }
    return null;
  }

  void dispose() {
    stopAllTracking();
  }
}