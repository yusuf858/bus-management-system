import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/bus_model.dart';
import '../core/models/route_model.dart';
import '../core/models/user_model.dart';
import '../core/services/database_service.dart';
import '../core/services/tracking_service.dart';
import '../core/models/live_location_model.dart';
import '../core/config/app_config.dart';

class BusProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final TrackingService _trackingService = TrackingService();

  List<BusModel> _buses = [];
  List<RouteModel> _routes = [];
  List<UserModel> _drivers = [];
  List<UserModel> _students = [];
  BusModel? _selectedBus;
  RouteModel? _selectedRoute;
  bool _isLoading = false;
  String? _errorMessage;

  // Live location tracking
  Map<String, LiveLocationModel> _liveLocations = {};

  // Stream subscriptions
  StreamSubscription<List<BusModel>>? _busesSubscription;
  StreamSubscription<List<RouteModel>>? _routesSubscription;

  // ← Track whether the current user is a driver
  bool _isDriver = false;

  // Statistics
  int _totalBuses = 0;
  int _activeBuses = 0;
  int _totalRoutes = 0;
  int _totalStudents = 0;
  int _totalDrivers = 0;

  // Getters
  List<BusModel> get buses => _buses;
  List<RouteModel> get routes => _routes;
  List<UserModel> get drivers => _drivers;
  List<UserModel> get students => _students;
  BusModel? get selectedBus => _selectedBus;
  RouteModel? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalBuses => _totalBuses;
  int get activeBuses => _activeBuses;
  int get totalRoutes => _totalRoutes;
  int get totalStudents => _totalStudents;
  int get totalDrivers => _totalDrivers;

  Map<String, LiveLocationModel> get liveLocations => _liveLocations;

  List<BusModel> get activeBusesList =>
      _buses.where((bus) => bus.isActive).toList();

  List<BusModel> get busesWithTrackers {
    if (AppConfig.USE_DEMO_MODE) {
      return _buses.where((bus) => bus.driverId != null && bus.driverId!.isNotEmpty).toList();
    } else {
      return _buses.where((bus) => bus.hasTracker).toList();
    }
  }

  List<UserModel> get unassignedDrivers =>
      _drivers.where((d) => d.assignedBusId == null).toList();

  /// Call this from HomeScreen after auth is known, so the provider
  /// knows whether to write GPS (driver) or read Firebase (admin/student).
  void setUserRole({required bool isDriver}) {
    _isDriver = isDriver;
    if (kDebugMode) {
      debugPrint('BusProvider role set: isDriver=$_isDriver');
    }
  }

  // Initialize streams
  void initializeStreams() {
    _busesSubscription?.cancel();
    _routesSubscription?.cancel();

    _busesSubscription = _databaseService.getBusesStream().listen(
          (busesList) {
        _buses = busesList;
        // Pass isDriver so only the driver's device writes GPS
        _trackingService.startTrackingBuses(
          busesWithTrackers,
          isDriver: _isDriver,
        );
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading buses: $error';
        notifyListeners();
      },
    );

    _routesSubscription = _databaseService.getRoutesStream().listen(
          (routesList) {
        _routes = routesList;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading routes: $error';
        notifyListeners();
      },
    );

    loadStatistics();
    loadDriversAndStudents();
  }

  // Load all data (one-time)
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _buses = await _databaseService.getAllBuses();
      _routes = await _databaseService.getAllRoutes();
      await loadStatistics();
      await loadDriversAndStudents();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _totalBuses = await _databaseService.getTotalBusesCount();
      _activeBuses = await _databaseService.getActiveBusesCount();
      _totalRoutes = await _databaseService.getTotalRoutesCount();
      _totalStudents = await _databaseService.getTotalStudentsCount();
      _totalDrivers = await _databaseService.getTotalDriversCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  // Load drivers and students
  Future<void> loadDriversAndStudents() async {
    try {
      _drivers = await _databaseService.getAllDrivers();
      _students = await _databaseService.getAllStudents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  void selectBus(BusModel? bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  void selectRoute(RouteModel? route) {
    _selectedRoute = route;
    notifyListeners();
  }

  Future<BusModel?> getBusById(String busId) async {
    try {
      return await _databaseService.getBus(busId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addBus(BusModel bus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.addBus(bus);
      await loadStatistics();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBus(String busId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateBus(busId, updates);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBus(String busId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteBus(busId);
      await loadStatistics();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addRoute(RouteModel route) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.addRoute(route);
      await loadStatistics();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoute(String routeId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateRoute(routeId, updates);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoute(String routeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteRoute(routeId);
      await loadStatistics();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  Future<bool> assignBusToDriver(String userId, String busId, String busNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.assignBusToDriver(userId, busId, busNumber);
      await loadDriversAndStudents();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignRouteToBus(String busId, String routeId, String routeName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.assignRouteToBus(busId, routeId, routeName);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== TRACKING OPERATIONS ====================

  /// Get live location for a bus.
  /// Automatically uses correct source based on role set via [setUserRole].
  Future<LiveLocationModel?> getLiveLocation(String busId) async {
    BusModel? bus;
    try {
      bus = _buses.firstWhere((b) => b.busId == busId);
    } catch (e) {
      debugPrint('Bus $busId not found in buses list');
      return null;
    }

    try {
      // isDriver=true  → writes GPS to Firebase
      // isDriver=false → reads from Firebase live_cache
      final location = await _trackingService.fetchLocation(
        bus,
        isDriver: _isDriver,
      );

      if (location != null) {
        _liveLocations[busId] = location;
        notifyListeners();
      }

      return location;
    } catch (e) {
      debugPrint('Error getting live location for bus $busId: $e');
      return null;
    }
  }

  /// Stream live location for a bus.
  /// Automatically uses correct source based on role set via [setUserRole].
  Stream<LiveLocationModel?> streamLiveLocation(String busId) {
    BusModel? bus;
    try {
      bus = _buses.firstWhere((b) => b.busId == busId);
    } catch (e) {
      debugPrint('Bus $busId not found in buses list');
      return Stream.value(null);
    }

    // isDriver=true  → streams GPS and writes to Firebase
    // isDriver=false → streams from Firebase live_cache
    return _trackingService.trackBus(bus, isDriver: _isDriver);
  }

  List<BusModel> getBusesByRoute(String routeId) {
    return _buses.where((bus) => bus.routeId == routeId).toList();
  }

  List<BusModel> searchBuses(String query) {
    if (query.isEmpty) return _buses;

    return _buses.where((bus) {
      return bus.busNumber.toLowerCase().contains(query.toLowerCase()) ||
          (bus.routeName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (bus.driverName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<RouteModel> searchRoutes(String query) {
    if (query.isEmpty) return _routes;

    return _routes.where((route) {
      return route.routeName.toLowerCase().contains(query.toLowerCase()) ||
          route.stops.any(
                (stop) => stop.name.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _busesSubscription?.cancel();
    _routesSubscription?.cancel();
    _trackingService.dispose();
    super.dispose();
  }
}