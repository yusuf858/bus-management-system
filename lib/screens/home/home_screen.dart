import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/notification_provider.dart';

// Import role-specific dashboards
import '../admin/admin_dashboard_screen.dart';
import '../driver/driver_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../tracking/live_tracking_screen.dart';
import '../routes/bus_routes_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authProvider = context.read<AuthProvider>();
    final busProvider = context.read<BusProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    // ← Tell BusProvider whether the logged-in user is a driver.
    //    Driver  → fetchLocation writes GPS to Firebase.
    //    Others  → fetchLocation reads from Firebase live_cache.
    busProvider.setUserRole(isDriver: authProvider.isDriver);

    // Build screens based on role
    _screens = _buildScreensForRole(authProvider);

    busProvider.initializeStreams();

    if (authProvider.currentUser != null) {
      notificationProvider.initializeNotificationStream(
        authProvider.currentUser!.uid,
      );
    }
  }

  List<Widget> _buildScreensForRole(AuthProvider authProvider) {
    if (authProvider.isAdmin) {
      return [
        const AdminDashboardScreen(),
        const LiveTrackingScreen(),
        const BusRoutesScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    } else if (authProvider.isDriver) {
      return [
        const DriverDashboardScreen(),
        const LiveTrackingScreen(),
        const BusRoutesScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const StudentDashboardScreen(),
        const LiveTrackingScreen(),
        const BusRoutesScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    _screens = _buildScreensForRole(authProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: navigateToTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Tracking',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Routes',
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}