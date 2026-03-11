import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/route_model.dart';
import '../../core/models/bus_model.dart';
import '../../core/services/map_service.dart';
import '../../providers/bus_provider.dart';

class ETAScreen extends StatefulWidget {
  final RouteModel route;
  final BusModel bus;

  const ETAScreen({
    super.key,
    required this.route,
    required this.bus,
  });

  @override
  State<ETAScreen> createState() => _ETAScreenState();
}

class _ETAScreenState extends State<ETAScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Timer? _updateTimer;
  Map<String, String> _stopETAs = {};
  int? _nextStopIndex;

  @override
  void initState() {
    super.initState();
    _startETAUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startETAUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _calculateETAs();
      }
    });

    // Initial calculation
    _calculateETAs();
  }

  Future<void> _calculateETAs() async {
    final busProvider = context.read<BusProvider>();
    final location = await busProvider.getLiveLocation(widget.bus.busId);

    if (location == null || !mounted) return;

    final busPosition = LatLng(location.latitude, location.longitude);
    final Map<String, String> newETAs = {};
    double? shortestDistance;
    int? closestStopIndex;

    for (int i = 0; i < widget.route.stops.length; i++) {
      final stop = widget.route.stops[i];
      final stopPosition = stop.position;

      final distance = _mapService.calculateDistance(busPosition, stopPosition);

      // Find closest stop
      if (shortestDistance == null || distance < shortestDistance) {
        shortestDistance = distance;
        closestStopIndex = i;
      }

      // Calculate ETA (assuming average speed of 30 km/h in city)
      final avgSpeed = 30.0; // km/h
      final timeInHours = (distance / 1000) / avgSpeed;
      final timeInMinutes = (timeInHours * 60).round();

      if (timeInMinutes < 1) {
        newETAs[stop.name] = 'Arriving now';
      } else if (timeInMinutes < 60) {
        newETAs[stop.name] = '$timeInMinutes min';
      } else {
        final hours = (timeInMinutes / 60).floor();
        final mins = timeInMinutes % 60;
        newETAs[stop.name] = '${hours}h ${mins}m';
      }
    }

    if (mounted) {
      setState(() {
        _stopETAs = newETAs;
        _nextStopIndex = closestStopIndex;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapService.setMapController(controller);

    // Fit bounds to show route
    if (widget.route.stops.isNotEmpty) {
      final positions = widget.route.stops.map((s) => s.position).toList();
      _mapService.fitBounds(positions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimated Arrival Time'),
      ),
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: 250,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: MapService.defaultCameraPosition,
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),

          // Bus Status
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus ${widget.bus.busNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.bus.isActive ? 'On Route' : 'Not Active',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_nextStopIndex != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Next: Stop ${_nextStopIndex! + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stops List with ETA
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.route.stops.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final stop = widget.route.stops[index];
                final eta = _stopETAs[stop.name] ?? 'Calculating...';
                final isNextStop = index == _nextStopIndex;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isNextStop
                          ? AppColors.primaryColor
                          : AppColors.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isNextStop
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isNextStop
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    stop.name,
                    style: TextStyle(
                      fontWeight: isNextStop ? FontWeight.bold : FontWeight.normal,
                      color: isNextStop
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: stop.arrivalTime != null
                      ? Text('Scheduled: ${stop.arrivalTime}')
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isNextStop
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eta,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isNextStop
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // Add stop markers
    for (int i = 0; i < widget.route.stops.length; i++) {
      final stop = widget.route.stops[i];
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: stop.position,
          infoWindow: InfoWindow(
            title: 'Stop ${i + 1}',
            snippet: stop.name,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == _nextStopIndex
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final positions = widget.route.stops.map((s) => s.position).toList();
    return {
      _mapService.createRoutePolyline(positions, widget.route.routeId),
    };
  }
}