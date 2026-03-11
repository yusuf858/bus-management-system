import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/stat_card.dart';
import '../home/home_screen.dart';
import '../student/route_selection_screen.dart';
import '../student/my_route_stops_screen.dart';
import '../student/eta_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final busProvider = context.watch<BusProvider>();
    final selectedRouteId = authProvider.currentUser?.selectedRouteId;

    // Safely get selected route
    final myRoute = selectedRouteId != null && busProvider.routes.isNotEmpty
        ? busProvider.routes.firstWhere(
          (r) => r.routeId == selectedRouteId,
      orElse: () => busProvider.routes.first,
    )
        : null;

    // Safely get assigned bus
    final myBus = myRoute?.assignedBusId != null && busProvider.buses.isNotEmpty
        ? busProvider.buses.firstWhere(
          (b) => b.busId == myRoute!.assignedBusId,
      orElse: () => busProvider.buses.first,
    )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            tooltip: 'Select Route',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteSelectionScreen(),
                ),
              );
            },
          ),
        ],
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
                        Icons.school,
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
                            authProvider.currentUser?.name ?? 'Student',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Student',
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

              // My Route Section
              if (selectedRouteId == null) ...[
                // No Route Selected
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.route,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Route Selected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please select your bus route to track your bus and view schedules',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RouteSelectionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.route),
                          label: const Text('Select Route'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Route Selected
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Route',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RouteSelectionScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (myRoute != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.route,
                                  color: AppColors.textWhite,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      myRoute.routeName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (myRoute.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        myRoute.description!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRouteInfo(
                                  icon: Icons.location_on,
                                  label: 'Stops',
                                  value: '${myRoute.totalStops}',
                                ),
                              ),
                              if (myRoute.distance != null)
                                Expanded(
                                  child: _buildRouteInfo(
                                    icon: Icons.straighten,
                                    label: 'Distance',
                                    value: myRoute.formattedDistance,
                                  ),
                                ),
                            ],
                          ),
                          if (myRoute.estimatedDuration != null) ...[
                            const SizedBox(height: 12),
                            _buildRouteInfo(
                              icon: Icons.access_time,
                              label: 'Est. Duration',
                              value: myRoute.formattedDuration,
                            ),
                          ],

                          // Bus Information
                          if (myBus != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.directions_bus,
                                    color: AppColors.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bus: ${myBus.busNumber}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: myBus.isActive
                                          ? AppColors.success.withValues(alpha: 0.2)
                                          : AppColors.warning.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      myBus.status ?? 'Idle',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: myBus.isActive
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No bus assigned to this route yet',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.warning,
                                      ),
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

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          icon: Icons.location_on,
                          label: 'Track Bus',
                          color: AppColors.success,
                          enabled: myBus != null,
                          onTap: () {
                            if (myBus != null) {
                              // Navigate to tracking tab (index 1)
                              _navigateToTab(context, 1);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No bus assigned to your route yet'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          icon: Icons.schedule,
                          label: 'View ETA',
                          color: AppColors.info,
                          enabled: myBus != null,
                          onTap: () {
                            if (myBus != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ETAScreen(
                                    route: myRoute,
                                    bus: myBus,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No bus assigned to your route yet'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          icon: Icons.route,
                          label: 'View Stops',
                          color: AppColors.accentColor,
                          enabled: true,
                          onTap: () {
                            // Navigate to My Route Stops screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyRouteStopsScreen(
                                  route: myRoute,
                                  bus: myBus,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          icon: Icons.notifications,
                          label: 'Notifications',
                          color: AppColors.primaryColor,
                          enabled: true,
                          onTap: () {
                            // Navigate to notifications tab (index 3)
                            _navigateToTab(context, 3);
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Route ID exists but route not found
                  Card(
                    color: AppColors.error.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Route Not Found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your selected route is no longer available. Please select a new route.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RouteSelectionScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.route),
                            label: const Text('Select New Route'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Statistics
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
                childAspectRatio: 1.3,
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
                    title: 'Tracked Buses',
                    value: busProvider.busesWithTrackers.length.toString(),
                    icon: Icons.location_on,
                    color: AppColors.info,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      color: enabled ? null : AppColors.surfaceColor,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (enabled ? color : AppColors.textSecondary).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : AppColors.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to navigate to tab
  void _navigateToTab(BuildContext context, int tabIndex) {
    // Find the HomeScreen's State and update the tab
    final homeScreenState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeScreenState != null) {
      homeScreenState.navigateToTab(tabIndex);
    }
  }
}