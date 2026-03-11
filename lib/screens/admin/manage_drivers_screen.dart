import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bus_provider.dart';

class ManageDriversScreen extends StatelessWidget {
  const ManageDriversScreen({super.key});

  void _showAssignBusDialog(BuildContext context, dynamic driver) {
    final busProvider = context.read<BusProvider>();
    final availableBuses = busProvider.buses
        .where((b) => b.driverId == null || b.driverId == driver.uid)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Bus to ${driver.name}'),
        content: availableBuses.isEmpty
            ? const Text('No buses available for assignment')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: availableBuses.map((bus) {
            return ListTile(
              leading: const Icon(Icons.directions_bus),
              title: Text('Bus ${bus.busNumber}'),
              subtitle: Text('Route: ${bus.routeName ?? "Not assigned"}'),
              onTap: () async {
                final success = await busProvider.assignBusToDriver(
                  driver.uid,
                  bus.busId,
                  bus.busNumber,
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
        title: const Text('Manage Drivers'),
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, _) {
          final drivers = busProvider.drivers;

          if (drivers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No drivers found', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final driver = drivers[index];
              final assignedBus = driver.assignedBusId != null
                  ? busProvider.buses.firstWhere(
                    (b) => b.busId == driver.assignedBusId,
                orElse: () => busProvider.buses.first,
              )
                  : null;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: driver.assignedBusId != null
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.warning.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: driver.assignedBusId != null
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  title: Text(
                    driver.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(driver.email),
                      if (driver.phoneNumber != null)
                        Text('Phone: ${driver.phoneNumber}'),
                      Text(
                        assignedBus != null
                            ? 'Assigned: Bus ${assignedBus.busNumber}'
                            : 'Not assigned to any bus',
                        style: TextStyle(
                          color: assignedBus != null
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment),
                    onPressed: () => _showAssignBusDialog(context, driver),
                    tooltip: 'Assign Bus',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}