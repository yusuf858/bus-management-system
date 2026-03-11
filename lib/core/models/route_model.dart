import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStop {
  final String name;
  final double latitude;
  final double longitude;
  final int orderIndex;
  final String? arrivalTime;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.orderIndex,
    this.arrivalTime,
  });

  factory BusStop.fromJson(Map<dynamic, dynamic> json) {
    return BusStop(
      name: json['name'] as String? ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'] as double)
          : 0.0,
      longitude: json['longitude'] != null
          ? (json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'] as double)
          : 0.0,
      orderIndex: json['orderIndex'] as int? ?? 0,
      arrivalTime: json['arrivalTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'orderIndex': orderIndex,
      'arrivalTime': arrivalTime,
    };
  }

  LatLng get position => LatLng(latitude, longitude);
}

class RouteModel {
  final String routeId;
  final String routeName;
  final List<BusStop> stops;
  final String? assignedBusId;
  final String? assignedBusNumber;
  final bool isActive;
  final String? description;
  final double? estimatedDuration; // in minutes
  final double? distance; // in kilometers

  RouteModel({
    required this.routeId,
    required this.routeName,
    required this.stops,
    this.assignedBusId,
    this.assignedBusNumber,
    this.isActive = true,
    this.description,
    this.estimatedDuration,
    this.distance,
  });

  factory RouteModel.fromJson(Map<dynamic, dynamic> json, String routeId) {
    List<BusStop> stopsList = [];

    if (json['stops'] != null) {
      if (json['stops'] is List) {
        stopsList = (json['stops'] as List)
            .map((stopJson) => BusStop.fromJson(stopJson as Map<dynamic, dynamic>))
            .toList();
      } else if (json['stops'] is Map) {
        // Handle case where stops might be stored as map
        final stopsMap = json['stops'] as Map<dynamic, dynamic>;
        stopsList = stopsMap.values
            .map((stopJson) => BusStop.fromJson(stopJson as Map<dynamic, dynamic>))
            .toList();
      }
    }

    // Sort stops by orderIndex
    stopsList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return RouteModel(
      routeId: routeId,
      routeName: json['routeName'] as String? ?? '',
      stops: stopsList,
      assignedBusId: json['assignedBusId'] as String?,
      assignedBusNumber: json['assignedBusNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      description: json['description'] as String?,
      estimatedDuration: json['estimatedDuration'] != null
          ? (json['estimatedDuration'] is int
          ? (json['estimatedDuration'] as int).toDouble()
          : json['estimatedDuration'] as double)
          : null,
      distance: json['distance'] != null
          ? (json['distance'] is int
          ? (json['distance'] as int).toDouble()
          : json['distance'] as double)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeName': routeName,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'assignedBusId': assignedBusId,
      'assignedBusNumber': assignedBusNumber,
      'isActive': isActive,
      'description': description,
      'estimatedDuration': estimatedDuration,
      'distance': distance,
    };
  }

  // Get total number of stops
  int get totalStops => stops.length;

  // Get formatted distance
  String get formattedDistance {
    if (distance == null) return 'N/A';
    return '${distance!.toStringAsFixed(1)} km';
  }

  // Get formatted duration
  String get formattedDuration {
    if (estimatedDuration == null) return 'N/A';

    final hours = (estimatedDuration! / 60).floor();
    final minutes = (estimatedDuration! % 60).floor();

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Copy with method
  RouteModel copyWith({
    String? routeId,
    String? routeName,
    List<BusStop>? stops,
    String? assignedBusId,
    String? assignedBusNumber,
    bool? isActive,
    String? description,
    double? estimatedDuration,
    double? distance,
  }) {
    return RouteModel(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      stops: stops ?? this.stops,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedBusNumber: assignedBusNumber ?? this.assignedBusNumber,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      distance: distance ?? this.distance,
    );
  }
}