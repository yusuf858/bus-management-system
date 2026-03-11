import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/bus_card.dart';
import '../../core/models/bus_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final busProvider = context.read<BusProvider>();
        busProvider.loadAllData();
      } catch (e) {
        // Handle error silently
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final busProvider = context.watch<BusProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Debug: Print role info
    debugPrint('User Role: ${user.role}');
    debugPrint('Is Admin: ${user.isAdmin}');
    debugPrint('Is Driver: ${user.isDriver}');
    debugPrint('Is Student: ${user.isStudent}');

    // Route to appropriate dashboard based on role
    if (user.isAdmin) {
      return _buildAdminDashboard(user, busProvider);
    } else if (user.isDriver) {
      return _buildDriverDashboard(user, busProvider);
    } else {
      return _buildStudentDashboard(user, busProvider);
    }
  }

  // ADMIN DASHBOARD
  Widget _buildAdminDashboard(user, BusProvider busProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => busProvider.loadAllData(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Feature - Coming Soon')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await busProvider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Welcome Card
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
                        color: Colors.white.withAlpha(61), // 0.24 * 255 = 61
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ADMINISTRATOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // System Overview
              const Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Admin Statistics Grid - FIXED OVERFLOW
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    'Total Buses',
                    '${busProvider.totalBuses}',
                    Icons.directions_bus,
                    AppColors.primaryColor,
                  ),
                  _buildStatCard(
                    'Active Buses',
                    '${busProvider.activeBuses}',
                    Icons.location_on,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Routes',
                    '${busProvider.totalRoutes}',
                    Icons.route,
                    AppColors.accentColor,
                  ),
                  _buildStatCard(
                    'Students',
                    '${busProvider.totalStudents}',
                    Icons.people,
                    AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Admin Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Add Bus',
                      Icons.add_circle_outline,
                      AppColors.primaryColor,
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add Bus - Coming Soon')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Add Route',
                      Icons.add_road,
                      AppColors.accentColor,
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add Route - Coming Soon')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Users',
                      Icons.people_outline,
                      AppColors.info,
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User Management - Coming Soon')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Reports',
                      Icons.analytics_outlined,
                      AppColors.success,
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reports - Coming Soon')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // All Buses Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Buses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View All Buses - Coming Soon')),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildBusList(busProvider),
            ],
          ),
        ),
      ),
    );
  }

  // DRIVER DASHBOARD
  Widget _buildDriverDashboard(user, BusProvider busProvider) {
    // FIXED: Handle nullable return type properly
    BusModel? assignedBus;

    if (user.assignedBusId != null) {
      try {
        assignedBus = busProvider.buses.firstWhere(
              (bus) => bus.busId == user.assignedBusId,
        );
      } catch (e) {
        // Bus not found, assignedBus remains null
        assignedBus = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => busProvider.loadAllData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await busProvider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Welcome Card
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
                        color: Colors.white.withAlpha(61), // 0.24 * 255 = 61
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'DRIVER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (assignedBus != null) ...[
                const Text(
                  'Your Assigned Bus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                BusCard(bus: assignedBus),
                const SizedBox(height: 20),

                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'Start Trip',
                  Icons.play_arrow,
                  AppColors.success,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Start Trip - Coming Soon')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'Update Location',
                  Icons.my_location,
                  AppColors.info,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update Location - Coming Soon')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'End Trip',
                  Icons.stop,
                  AppColors.error,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('End Trip - Coming Soon')),
                    );
                  },
                ),
              ] else ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_bus_outlined,
                        size: 80,
                        color: AppColors.textSecondary.withAlpha(128), // 0.5 * 255 = 128
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bus Assigned',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please contact administrator',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // STUDENT DASHBOARD
  Widget _buildStudentDashboard(user, BusProvider busProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => busProvider.loadAllData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await busProvider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withAlpha(61), // 0.24 * 255 = 61
                      child: const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(61), // 0.24 * 255 = 61
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'STUDENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Grid - FIXED OVERFLOW
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    'Total Buses',
                    '${busProvider.totalBuses}',
                    Icons.directions_bus,
                    AppColors.primaryColor,
                  ),
                  _buildStatCard(
                    'Active Buses',
                    '${busProvider.activeBuses}',
                    Icons.location_on,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Routes',
                    '${busProvider.totalRoutes}',
                    Icons.route,
                    AppColors.accentColor,
                  ),
                  _buildStatCard(
                    'Students',
                    '${busProvider.totalStudents}',
                    Icons.people,
                    AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Active Buses Section
              const Text(
                'Active Buses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildBusList(busProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Stat Card Widget - FIXED OVERFLOW
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Bus List Widget
  Widget _buildBusList(BusProvider busProvider) {
    if (busProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (busProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Error loading buses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                busProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final activeBuses = busProvider.activeBusesList;

    if (activeBuses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.directions_bus,
                size: 64,
                color: AppColors.textSecondary.withAlpha(128), // 0.5 * 255 = 128
              ),
              const SizedBox(height: 16),
              const Text(
                'No active buses',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeBuses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return BusCard(bus: activeBuses[index]);
      },
    );
  }
}