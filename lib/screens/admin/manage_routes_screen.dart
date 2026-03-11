import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/route_card.dart';

class ManageRoutesScreen extends StatelessWidget {
  const ManageRoutesScreen({super.key});

  void _showAssignBusDialog(BuildContext context, dynamic route) {
    final busProvider = context.read<BusProvider>();
    final availableBuses = busProvider.buses
        .where((b) => b.routeId == null || b.routeId == route.routeId)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Bus to ${route.routeName}'),
        content: availableBuses.isEmpty
            ? const Text('No buses available for assignment')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: availableBuses.map((bus) {
            return ListTile(
              leading: const Icon(Icons.directions_bus),
              title: Text('Bus ${bus.busNumber}'),
              subtitle: Text(
                'Driver: ${bus.driverName ?? "Not assigned"}',
              ),
              onTap: () async {
                final success = await busProvider.assignRouteToBus(
                  bus.busId,
                  route.routeId,
                  route.routeName,
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Bus assigned successfully'
                            : 'Failed to assign bus',
                      ),
                      backgroundColor:
                      success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, _) {
          final routes = busProvider.routes;

          if (routes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No routes found', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final route = routes[index];

              return Card(
                child: Column(
                  children: [
                    RouteCard(route: route),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAssignBusDialog(context, route),
                        icon: const Icon(Icons.assignment),
                        label: Text(
                          route.assignedBusNumber != null
                              ? 'Change Bus Assignment'
                              : 'Assign Bus',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}