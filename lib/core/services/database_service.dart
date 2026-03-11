import 'package:firebase_database/firebase_database.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // ==================== BUS OPERATIONS ====================

  // Get all buses stream
  Stream<List<BusModel>> getBusesStream() {
    return _database.child('buses').onValue.map((event) {
      final List<BusModel> buses = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          buses.add(BusModel.fromJson(value as Map<dynamic, dynamic>, key as String));
        });
      }
      return buses;
    });
  }

  // Get single bus stream
  Stream<BusModel?> getBusStream(String busId) {
    return _database.child('buses/$busId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return BusModel.fromJson(data, busId);
      }
      return null;
    });
  }

  // Get bus by ID (one-time read)
  Future<BusModel?> getBus(String busId) async {
    try {
      final snapshot = await _database.child('buses/$busId').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return BusModel.fromJson(data, busId);
      }
      return null;
    } catch (e) {
      throw 'Error fetching bus: ${e.toString()}';
    }
  }

  // Get all buses (one-time read)
  Future<List<BusModel>> getAllBuses() async {
    try {
      final snapshot = await _database.child('buses').get();
      final List<BusModel> buses = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          buses.add(BusModel.fromJson(value as Map<dynamic, dynamic>, key as String));
        });
      }
      return buses;
    } catch (e) {
      throw 'Error fetching buses: ${e.toString()}';
    }
  }

  // Add new bus
  Future<String> addBus(BusModel bus) async {
    try {
      final newBusRef = _database.child('buses').push();
      await newBusRef.set(bus.toJson());
      return newBusRef.key!;
    } catch (e) {
      throw 'Error adding bus: ${e.toString()}';
    }
  }

  // Update bus
  Future<void> updateBus(String busId, Map<String, dynamic> updates) async {
    try {
      await _database.child('buses/$busId').update(updates);
    } catch (e) {
      throw 'Error updating bus: ${e.toString()}';
    }
  }

  // Delete bus
  Future<void> deleteBus(String busId) async {
    try {
      await _database.child('buses/$busId').remove();
    } catch (e) {
      throw 'Error deleting bus: ${e.toString()}';
    }
  }

  // ==================== ROUTE OPERATIONS ====================

  // Get all routes stream
  Stream<List<RouteModel>> getRoutesStream() {
    return _database.child('routes').onValue.map((event) {
      final List<RouteModel> routes = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          routes.add(RouteModel.fromJson(value as Map<dynamic, dynamic>, key as String));
        });
      }
      return routes;
    });
  }

  // Get single route stream
  Stream<RouteModel?> getRouteStream(String routeId) {
    return _database.child('routes/$routeId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return RouteModel.fromJson(data, routeId);
      }
      return null;
    });
  }

  // Get route by ID
  Future<RouteModel?> getRoute(String routeId) async {
    try {
      final snapshot = await _database.child('routes/$routeId').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return RouteModel.fromJson(data, routeId);
      }
      return null;
    } catch (e) {
      throw 'Error fetching route: ${e.toString()}';
    }
  }

  // Get all routes (one-time read)
  Future<List<RouteModel>> getAllRoutes() async {
    try {
      final snapshot = await _database.child('routes').get();
      final List<RouteModel> routes = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          routes.add(RouteModel.fromJson(value as Map<dynamic, dynamic>, key as String));
        });
      }
      return routes;
    } catch (e) {
      throw 'Error fetching routes: ${e.toString()}';
    }
  }

  // Add new route
  Future<String> addRoute(RouteModel route) async {
    try {
      final newRouteRef = _database.child('routes').push();
      await newRouteRef.set(route.toJson());
      return newRouteRef.key!;
    } catch (e) {
      throw 'Error adding route: ${e.toString()}';
    }
  }

  // Update route
  Future<void> updateRoute(String routeId, Map<String, dynamic> updates) async {
    try {
      await _database.child('routes/$routeId').update(updates);
    } catch (e) {
      throw 'Error updating route: ${e.toString()}';
    }
  }

  // Delete route
  Future<void> deleteRoute(String routeId) async {
    try {
      await _database.child('routes/$routeId').remove();
    } catch (e) {
      throw 'Error deleting route: ${e.toString()}';
    }
  }

  // Toggle route active status
  Future<void> toggleRouteStatus(String routeId, bool isActive) async {
    try {
      await _database.child('routes/$routeId').update({'isActive': isActive});
    } catch (e) {
      throw 'Error toggling route status: ${e.toString()}';
    }
  }

  // ==================== USER OPERATIONS (FIXED) ====================

  // Get all users stream
  Stream<List<UserModel>> getUsersStream() {
    return _database.child('users').onValue.map((event) {
      final List<UserModel> users = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          users.add(UserModel.fromJson(value as Map<dynamic, dynamic>, key as String));
        });
      }
      return users;
    });
  }

  // Get all users by role (CORRECTED)
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _database.child('users').get();
      final List<UserModel> users = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final userData = value as Map<dynamic, dynamic>;
          // Case-insensitive role comparison
          if (userData['role']?.toString().toLowerCase() == role.toLowerCase()) {
            users.add(UserModel.fromJson(userData, key as String));
          }
        });
      }
      return users;
    } catch (e) {
      throw 'Error fetching users by role: ${e.toString()}';
    }
  }

  // Get all drivers
  Future<List<UserModel>> getAllDrivers() async {
    return await getUsersByRole('Driver');
  }

  // Get all students
  Future<List<UserModel>> getAllStudents() async {
    return await getUsersByRole('Student');
  }

  // Get all admins
  Future<List<UserModel>> getAllAdmins() async {
    return await getUsersByRole('Admin');
  }

  // Assign bus to driver
  Future<void> assignBusToDriver(String userId, String busId, String busNumber) async {
    try {
      // Update user
      await _database.child('users/$userId').update({
        'assignedBusId': busId,
      });

      // Get user name
      final userSnapshot = await _database.child('users/$userId').get();
      String driverName = 'Unknown';
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        driverName = userData['name'] as String? ?? 'Unknown';
      }

      // Update bus
      await _database.child('buses/$busId').update({
        'driverId': userId,
        'driverName': driverName,
      });
    } catch (e) {
      throw 'Error assigning bus to driver: ${e.toString()}';
    }
  }

  // Assign route to bus
  Future<void> assignRouteToBus(String busId, String routeId, String routeName) async {
    try {
      await _database.child('buses/$busId').update({
        'routeId': routeId,
        'routeName': routeName,
      });

      // Update route with assigned bus
      final bus = await getBus(busId);
      if (bus != null) {
        await _database.child('routes/$routeId').update({
          'assignedBusId': busId,
          'assignedBusNumber': bus.busNumber,
        });
      }
    } catch (e) {
      throw 'Error assigning route to bus: ${e.toString()}';
    }
  }

  // ==================== NOTIFICATION OPERATIONS (FIXED) ====================

  // Get user notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _database
        .child('notifications/$userId')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final List<NotificationModel> notifications = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          notifications.add(
            NotificationModel.fromJson(value as Map<dynamic, dynamic>, key as String),
          );
        });
      }
      // Sort by timestamp descending (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications;
    });
  }

  // Add notification
  Future<String> addNotification(String userId, NotificationModel notification) async {
    try {
      final newNotifRef = _database.child('notifications/$userId').push();
      await newNotifRef.set(notification.toJson());
      return newNotifRef.key!;
    } catch (e) {
      throw 'Error adding notification: ${e.toString()}';
    }
  }

  // Send notification to all users on a route (FIXED)
  Future<void> sendNotificationToRoute(String routeId, NotificationModel notification) async {
    try {
      // Get all students with this route selected
      final students = await getAllStudents();
      final routeStudents = students.where((s) => s.selectedRouteId == routeId).toList();

      // Get driver assigned to this route's bus
      final buses = await getAllBuses();
      final routeBuses = buses.where((b) => b.routeId == routeId).toList();

      // Send to all drivers of buses on this route
      for (var bus in routeBuses) {
        if (bus.driverId != null && bus.driverId!.isNotEmpty) {
          try {
            await addNotification(bus.driverId!, notification);
          } catch (e) {
            // Continue even if one notification fails
            print('Failed to send notification to driver ${bus.driverId}: $e');
          }
        }
      }

      // Send to all students on this route
      for (var student in routeStudents) {
        try {
          await addNotification(student.uid, notification);
        } catch (e) {
          // Continue even if one notification fails
          print('Failed to send notification to student ${student.uid}: $e');
        }
      }
    } catch (e) {
      throw 'Error sending notification to route: ${e.toString()}';
    }
  }

  // Send notification to all users on a bus (FIXED)
  Future<void> sendNotificationToBus(String busId, NotificationModel notification) async {
    try {
      final bus = await getBus(busId);
      if (bus == null) return;

      // Send to driver
      if (bus.driverId != null && bus.driverId!.isNotEmpty) {
        try {
          await addNotification(bus.driverId!, notification);
        } catch (e) {
          print('Failed to send notification to driver: $e');
        }
      }

      // Send to students on this route
      if (bus.routeId != null && bus.routeId!.isNotEmpty) {
        final students = await getAllStudents();
        final routeStudents = students.where((s) => s.selectedRouteId == bus.routeId).toList();

        for (var student in routeStudents) {
          try {
            await addNotification(student.uid, notification);
          } catch (e) {
            print('Failed to send notification to student ${student.uid}: $e');
          }
        }
      }
    } catch (e) {
      throw 'Error sending notification to bus: ${e.toString()}';
    }
  }

  // Send notification to specific role
  Future<void> sendNotificationToRole(String role, NotificationModel notification) async {
    try {
      final users = await getUsersByRole(role);

      for (var user in users) {
        await addNotification(user.uid, notification);
      }
    } catch (e) {
      throw 'Error sending notification to role: ${e.toString()}';
    }
  }

  // Send notification to all users (FIXED VERSION)
  Future<void> sendNotificationToAll(NotificationModel notification) async {
    try {
      // Get users by role instead of reading entire users node
      // This respects Firebase security rules
      final admins = await getUsersByRole('Admin');
      final drivers = await getUsersByRole('Driver');
      final students = await getUsersByRole('Student');

      // Combine all users
      final allUsers = [...admins, ...drivers, ...students];

      // Send to each user
      for (var user in allUsers) {
        await addNotification(user.uid, notification);
      }
    } catch (e) {
      throw 'Error sending notification to all: ${e.toString()}';
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _database.child('notifications/$userId/$notificationId').update({
        'isRead': true,
      });
    } catch (e) {
      throw 'Error marking notification as read: ${e.toString()}';
    }
  }

  // Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _database.child('notifications/$userId/$notificationId').remove();
    } catch (e) {
      throw 'Error deleting notification: ${e.toString()}';
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      await _database.child('notifications/$userId').remove();
    } catch (e) {
      throw 'Error clearing notifications: ${e.toString()}';
    }
  }

  // ==================== STATISTICS ====================

  // Get total buses count
  Future<int> getTotalBusesCount() async {
    try {
      final snapshot = await _database.child('buses').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get active buses count
  Future<int> getActiveBusesCount() async {
    try {
      final snapshot = await _database.child('buses').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;
        data.forEach((key, value) {
          final bus = value as Map<dynamic, dynamic>;
          if (bus['isActive'] == true) count++;
        });
        return count;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get total routes count
  Future<int> getTotalRoutesCount() async {
    try {
      final snapshot = await _database.child('routes').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get total students count
  Future<int> getTotalStudentsCount() async {
    try {
      final students = await getAllStudents();
      return students.length;
    } catch (e) {
      return 0;
    }
  }

  // Get total drivers count
  Future<int> getTotalDriversCount() async {
    try {
      final drivers = await getAllDrivers();
      return drivers.length;
    } catch (e) {
      return 0;
    }
  }
}