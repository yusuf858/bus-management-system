import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusModel {
  final String busId;
  final String busNumber;
  final String? driverId;
  final String? driverName;
  final String? routeId;
  final String? routeName;
  final String? trackerDeviceId; // NEW FIELD
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdated;
  final bool isActive;
  final int capacity;
  final int currentOccupancy;
  final String? status; // 'On Route', 'Idle', 'Maintenance'

  BusModel({
    required this.busId,
    required this.busNumber,
    this.driverId,
    this.driverName,
    this.routeId,
    this.routeName,
    this.trackerDeviceId, // NEW
    this.latitude,
    this.longitude,
    this.lastUpdated,
    this.isActive = false,
    this.capacity = 50,
    this.currentOccupancy = 0,
    this.status = 'Idle',
  });

  // Convert from JSON (Firebase)
  factory BusModel.fromJson(Map<dynamic, dynamic> json, String busId) {
    return BusModel(
      busId: busId,
      busNumber: json['busNumber'] as String? ?? '',
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      trackerDeviceId: json['trackerDeviceId'] as String?, // NEW
      latitude: json['latitude'] != null
          ? (json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'] as double)
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'] as double)
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      capacity: json['capacity'] as int? ?? 50,
      currentOccupancy: json['currentOccupancy'] as int? ?? 0,
      status: json['status'] as String? ?? 'Idle',
    );
  }

  // Convert to JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'busNumber': busNumber,
      'driverId': driverId,
      'driverName': driverName,
      'routeId': routeId,
      'routeName': routeName,
      'trackerDeviceId': trackerDeviceId, // NEW
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'isActive': isActive,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'status': status,
    };
  }

  // Get LatLng for Google Maps
  LatLng? get position {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  // Check if bus has valid location
  bool get hasLocation => latitude != null && longitude != null;

  // Check if bus has tracker
  bool get hasTracker => trackerDeviceId != null && trackerDeviceId!.isNotEmpty;

  // Get formatted last update time
  String get formattedLastUpdate {
    if (lastUpdated == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Copy with method
  BusModel copyWith({
    String? busId,
    String? busNumber,
    String? driverId,
    String? driverName,
    String? routeId,
    String? routeName,
    String? trackerDeviceId, // NEW
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
    bool? isActive,
    int? capacity,
    int? currentOccupancy,
    String? status,
  }) {
    return BusModel(
      busId: busId ?? this.busId,
      busNumber: busNumber ?? this.busNumber,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      trackerDeviceId: trackerDeviceId ?? this.trackerDeviceId, // NEW
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      status: status ?? this.status,
    );
  }
}