import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/bus_model.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ManageBusesScreen extends StatefulWidget {
  const ManageBusesScreen({super.key});

  @override
  State<ManageBusesScreen> createState() => _ManageBusesScreenState();
}

class _ManageBusesScreenState extends State<ManageBusesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBusDialog() {
    final busNumberController = TextEditingController();
    final trackerIdController = TextEditingController();
    final capacityController = TextEditingController(text: '50');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Bus'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: busNumberController,
                  label: 'Bus Number',
                  hint: 'e.g., KA-01-AB-1234',
                  prefixIcon: Icons.directions_bus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bus number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: trackerIdController,
                  label: 'Tracker Device ID',
                  hint: 'WheelsEye Device ID',
                  prefixIcon: Icons.gps_fixed,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tracker device ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: capacityController,
                  label: 'Capacity',
                  hint: 'Number of seats',
                  prefixIcon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter capacity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final busProvider = context.read<BusProvider>();

                final newBus = BusModel(
                  busId: '',
                  busNumber: busNumberController.text.trim(),
                  trackerDeviceId: trackerIdController.text.trim(),
                  capacity: int.parse(capacityController.text),
                  isActive: false,
                  status: 'Idle',
                );

                final success = await busProvider.addBus(newBus);

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Bus added successfully' : 'Failed to add bus',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBusDialog(BusModel bus) {
    final trackerIdController = TextEditingController(text: bus.trackerDeviceId);
    final capacityController = TextEditingController(text: bus.capacity.toString());
    final formKey = GlobalKey<FormState>();
    String status = bus.status ?? 'Idle';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Bus ${bus.busNumber}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: trackerIdController,
                  label: 'Tracker Device ID',
                  hint: 'WheelsEye Device ID',
                  prefixIcon: Icons.gps_fixed,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: capacityController,
                  label: 'Capacity',
                  hint: 'Number of seats',
                  prefixIcon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Idle', child: Text('Idle')),
                    DropdownMenuItem(value: 'On Route', child: Text('On Route')),
                    DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (value) {
                    if (value != null) status = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final busProvider = context.read<BusProvider>();

              final updates = {
                'trackerDeviceId': trackerIdController.text.trim(),
                'capacity': int.parse(capacityController.text),
                'status': status,
              };

              final success = await busProvider.updateBus(bus.busId, updates);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Bus updated successfully' : 'Failed to update bus',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BusModel bus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: Text('Are you sure you want to delete bus ${bus.busNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final busProvider = context.read<BusProvider>();
              final success = await busProvider.deleteBus(bus.busId);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Bus deleted successfully' : 'Failed to delete bus',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Buses'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search buses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Bus List
          Expanded(
            child: Consumer<BusProvider>(
              builder: (context, busProvider, _) {
                final buses = _searchQuery.isEmpty
                    ? busProvider.buses
                    : busProvider.searchBuses(_searchQuery);

                if (buses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text('No buses found', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: buses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bus = buses[index];

                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bus.hasTracker
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_bus,
                            color: bus.hasTracker ? AppColors.success : AppColors.error,
                          ),
                        ),
                        title: Text(
                          'Bus ${bus.busNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Route: ${bus.routeName ?? "Not assigned"}'),
                            Text('Driver: ${bus.driverName ?? "Not assigned"}'),
                            Text('Tracker: ${bus.trackerDeviceId ?? "Not assigned"}'),
                            Text('Status: ${bus.status}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditBusDialog(bus);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(bus);
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBusDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Bus'),
      ),
    );
  }
}