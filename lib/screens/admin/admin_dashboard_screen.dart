import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/admin_action_card.dart';
import 'manage_buses_screen.dart';
import 'manage_drivers_screen.dart';
import 'manage_students_screen.dart';
import 'manage_routes_screen.dart';
import 'send_notification_screen.dart';
import 'route_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final busProvider = context.watch<BusProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => busProvider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.currentUser?.name ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Transport Administrator',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Grid
              const Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    title: 'Total Buses',
                    value: busProvider.totalBuses.toString(),
                    icon: Icons.directions_bus,
                    color: AppColors.primaryColor,
                  ),
                  StatCard(
                    title: 'Active Buses',
                    value: busProvider.activeBuses.toString(),
                    icon: Icons.gps_fixed,
                    color: AppColors.success,
                  ),
                  StatCard(
                    title: 'Total Routes',
                    value: busProvider.totalRoutes.toString(),
                    icon: Icons.route,
                    color: AppColors.accentColor,
                  ),
                  StatCard(
                    title: 'Total Drivers',
                    value: busProvider.totalDrivers.toString(),
                    icon: Icons.person,
                    color: AppColors.info,
                  ),
                  StatCard(
                    title: 'Total Students',
                    value: busProvider.totalStudents.toString(),
                    icon: Icons.school,
                    color: AppColors.warning,
                  ),
                  StatCard(
                    title: 'Tracked Buses',
                    value: busProvider.busesWithTrackers.length.toString(),
                    icon: Icons.location_on,
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              AdminActionCard(
                icon: Icons.directions_bus,
                title: 'Manage Buses',
                description: 'Add, edit, or remove buses',
                color: AppColors.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageBusesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              AdminActionCard(
                icon: Icons.route,
                title: 'Manage Routes',
                description: 'Configure bus routes and stops',
                color: AppColors.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageRoutesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              AdminActionCard(
                icon: Icons.person,
                title: 'Manage Drivers',
                description: 'Assign drivers to buses',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageDriversScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              AdminActionCard(
                icon: Icons.route,
                title: 'Route Management',
                description: 'Complete route CRUD operations',
                color: AppColors.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RouteManagementScreen(),
                    ),
                  );
                },
              ),

              AdminActionCard(
                icon: Icons.school,
                title: 'Manage Students',
                description: 'View and manage student accounts',
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageStudentsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              AdminActionCard(
                icon: Icons.notifications,
                title: 'Send Notifications',
                description: 'Broadcast messages to users',
                color: AppColors.error,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendNotificationScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}