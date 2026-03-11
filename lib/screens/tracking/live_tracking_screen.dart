import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/map_service.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/bus_model.dart';
import '../../core/models/live_location_model.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BusModel? _selectedBus;
  bool _isInitialized = false;
  Timer? _updateTimer;
  Map<String, LiveLocationModel> _currentLocations = {};

  @override
  void dispose() {
    _updateTimer?.cancel();
    _mapService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;

    _mapController = controller;
    _mapService.setMapController(controller);

    setState(() {
      _isInitialized = true;
    });

    // Start periodic updates
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _updateTimer?.cancel();

    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchAllBusLocations();
      }
    });
  }

  Future<void> _fetchAllBusLocations() async {
    final busProvider = context.read<BusProvider>();
    final buses = busProvider.busesWithTrackers;

    for (var bus in buses) {
      try {
        final location = await busProvider.getLiveLocation(bus.busId);
        if (location != null && mounted) {
          setState(() {
            _currentLocations[bus.busId] = location;
          });
        }
      } catch (e) {
        debugPrint('Error fetching location for ${bus.busId}: $e');
      }
    }

    if (mounted) {
      await _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (!_isInitialized || !mounted) return;

    try {
      final Set<Marker> markers = {};
      final busProvider = context.read<BusProvider>();

      for (var entry in _currentLocations.entries) {
        final busId = entry.key;
        final location = entry.value;

        final bus = busProvider.buses.firstWhere(
              (b) => b.busId == busId,
          orElse: () => busProvider.buses.first,
        );

        final marker = Marker(
          markerId: MarkerId(busId),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: 'Bus ${bus.busNumber}',
            snippet: '${location.formattedSpeed} • ${location.lastUpdated.toString().substring(11, 16)}',
          ),
          icon: await _getBusIcon(location.ignition ?? true),
          rotation: 0,
        );

        markers.add(marker);
      }

      if (mounted) {
        setState(() {
          _markers = markers;
        });
      }
    } catch (e) {
      debugPrint('Error updating markers: $e');
    }
  }

  Future<BitmapDescriptor> _getBusIcon(bool isMoving) async {
    return BitmapDescriptor.defaultMarkerWithHue(
      isMoving ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
    );
  }

  void _selectBus(BusModel bus) {
    if (!mounted) return;

    setState(() {
      _selectedBus = bus;
    });

    final location = _currentLocations[bus.busId];
    if (location != null) {
      try {
        _mapService.moveCameraToPosition(
          LatLng(location.latitude, location.longitude),
        );
      } catch (e) {
        debugPrint('Error moving camera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          if (_selectedBus != null)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: () {
                final location = _currentLocations[_selectedBus!.busId];
                if (location != null) {
                  _mapService.moveCameraToPosition(
                    LatLng(location.latitude, location.longitude),
                  );
                }
              },
              tooltip: 'Center on bus',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllBusLocations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, _) {
          // Filter buses based on role
          List<BusModel> displayBuses;

          if (authProvider.isStudent) {
            // Students see only their route's bus
            final routeId = authProvider.currentUser?.selectedRouteId;
            if (routeId != null) {
              displayBuses = busProvider.buses
                  .where((b) => b.routeId == routeId && b.hasTracker)
                  .toList();
            } else {
              displayBuses = [];
            }
          } else if (authProvider.isDriver) {
            // Drivers see only their assigned bus
            final assignedBusId = authProvider.currentUser?.assignedBusId;
            if (assignedBusId != null) {
              displayBuses = busProvider.buses
                  .where((b) => b.busId == assignedBusId && b.hasTracker)
                  .toList();
            } else {
              displayBuses = [];
            }
          } else {
            // Admin sees all buses with trackers
            displayBuses = busProvider.busesWithTrackers;
          }

          return Column(
            children: [
              // Bus Info Banner (if bus selected)
              if (_selectedBus != null && _currentLocations.containsKey(_selectedBus!.busId))
                _buildBusInfo(_selectedBus!, _currentLocations[_selectedBus!.busId]!),

              // Google Map
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: MapService.defaultCameraPosition,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                    ),

                    // Loading indicator
                    if (!_isInitialized)
                      Container(
                        color: AppColors.backgroundColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // No active buses message
                    if (_isInitialized && displayBuses.isEmpty)
                      Container(
                        color: AppColors.backgroundColor.withOpacity(0.9),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_bus_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                authProvider.isStudent
                                    ? 'No Bus on Your Route'
                                    : 'No Active Buses',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                authProvider.isStudent
                                    ? 'Please select a route in your profile'
                                    : 'There are no buses currently active',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Bus List
              if (displayBuses.isNotEmpty) _buildBusList(displayBuses),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusInfo(BusModel bus, LiveLocationModel location) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryColor,
      child: SafeArea(
        bottom: false,
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
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bus ${bus.busNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        location.ignition ?? false
                            ? Icons.directions_car
                            : Icons.local_parking,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.formattedSpeed,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        location.lastUpdated.toString().substring(11, 16),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (bus.routeName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      bus.routeName!,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _selectedBus = null;
                  });
                }
              },
              tooltip: 'Close',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusList(List<BusModel> buses) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 130,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                const Text(
                  'Tracked Buses',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${buses.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
                final isSelected = _selectedBus?.busId == bus.busId;
                final location = _currentLocations[bus.busId];

                return GestureDetector(
                  onTap: () => _selectBus(bus),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bus.busNumber,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location?.formattedSpeed ?? 'N/A',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
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
}