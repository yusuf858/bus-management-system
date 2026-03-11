import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';

class MapService {
  GoogleMapController? _mapController;

  // Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // Dispose map controller
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
  }

  // Create bus marker
  Future<Marker> createBusMarker(BusModel bus) async {
    return Marker(
      markerId: MarkerId(bus.busId),
      position: bus.position ?? const LatLng(0, 0),
      infoWindow: InfoWindow(
        title: 'Bus ${bus.busNumber}',
        snippet: 'Route: ${bus.routeName ?? "N/A"} - ${bus.status}',
      ),
      icon: await _getBusIcon(bus.isActive),
      rotation: 0,
    );
  }

  // Create stop marker
  Marker createStopMarker(BusStop stop, int index) {
    return Marker(
      markerId: MarkerId('stop_${stop.orderIndex}'),
      position: stop.position,
      infoWindow: InfoWindow(
        title: 'Stop ${index + 1}',
        snippet: stop.name,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
  }

  // Get bus icon based on active status
  Future<BitmapDescriptor> _getBusIcon(bool isActive) async {
    // In production, you would use custom icons
    // For now, using default markers with different colors
    return BitmapDescriptor.defaultMarkerWithHue(
      isActive ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
    );
  }

  // Move camera to position
  Future<void> moveCameraToPosition(LatLng position, {double zoom = 15}) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: zoom,
          ),
        ),
      );
    }
  }

  // Fit bounds to show all markers
  Future<void> fitBounds(List<LatLng> positions) async {
    if (_mapController == null || positions.isEmpty) return;

    if (positions.length == 1) {
      await moveCameraToPosition(positions.first);
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  // Calculate distance between two points (in meters)
  // Using Haversine formula
  double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371000; // meters

    double dLat = _toRadians(to.latitude - from.latitude);
    double dLng = _toRadians(to.longitude - from.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(from.latitude)) *
            math.cos(_toRadians(to.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  // Format distance
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Create polyline for route
  Polyline createRoutePolyline(List<LatLng> points, String routeId) {
    return Polyline(
      polylineId: PolylineId(routeId),
      points: points,
      color: const Color(0xFF7B1E1E),
      width: 5,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );
  }

  // Create circle for geofence
  Circle createGeofence(LatLng center, double radius, String id) {
    return Circle(
      circleId: CircleId(id),
      center: center,
      radius: radius,
      fillColor: const Color(0xFF7B1E1E).withAlpha((0.2 * 255).toInt()),
      strokeColor: const Color(0xFF7B1E1E),
      strokeWidth: 2,
    );
  }

  // Default camera position (can be changed based on your location)
  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: LatLng(15.8497, 74.4977), // Belagavi, Karnataka
    zoom: 12,
  );

  // Map styles (optional)
  static const String mapStyleJson = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';
}