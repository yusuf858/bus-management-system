import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/route_model.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/route_card.dart';

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddRouteDialog() {
    final routeNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final distanceController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<BusStop> stops = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Route'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: routeNameController,
                    label: 'Route Name',
                    hint: 'e.g., Route 1: College to City',
                    prefixIcon: Icons.route,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter route name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    label: 'Description (Optional)',
                    hint: 'Route description',
                    prefixIcon: Icons.description,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: distanceController,
                          label: 'Distance (km)',
                          hint: '0.0',
                          prefixIcon: Icons.straighten,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: durationController,
                          label: 'Duration (min)',
                          hint: '0',
                          prefixIcon: Icons.access_time,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Bus Stops',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          _showAddStopDialog(context, (stop) {
                            setDialogState(() {
                              stops.add(stop);
                              stops.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Stop'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (stops.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No stops added yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: stops.length,
                        onReorder: (oldIndex, newIndex) {
                          setDialogState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final stop = stops.removeAt(oldIndex);
                            stops.insert(newIndex, stop);
                            // Update order indices
                            for (int i = 0; i < stops.length; i++) {
                              stops[i] = BusStop(
                                name: stops[i].name,
                                latitude: stops[i].latitude,
                                longitude: stops[i].longitude,
                                orderIndex: i + 1,
                                arrivalTime: stops[i].arrivalTime,
                              );
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          final stop = stops[index];
                          return ListTile(
                            key: ValueKey(stop.name),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                              child: Text(
                                '${stop.orderIndex}',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(stop.name),
                            subtitle: Text(
                              stop.arrivalTime ?? 'No time set',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () {
                                setDialogState(() {
                                  stops.removeAt(index);
                                  // Reindex
                                  for (int i = 0; i < stops.length; i++) {
                                    stops[i] = BusStop(
                                      name: stops[i].name,
                                      latitude: stops[i].latitude,
                                      longitude: stops[i].longitude,
                                      orderIndex: i + 1,
                                      arrivalTime: stops[i].arrivalTime,
                                    );
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
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
                  if (stops.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one stop'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }

                  final busProvider = context.read<BusProvider>();

                  final newRoute = RouteModel(
                    routeId: '',
                    routeName: routeNameController.text.trim(),
                    stops: stops,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    distance: distanceController.text.isEmpty
                        ? null
                        : double.tryParse(distanceController.text),
                    estimatedDuration: durationController.text.isEmpty
                        ? null
                        : double.tryParse(durationController.text),
                    isActive: true,
                  );

                  final success = await busProvider.addRoute(newRoute);

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Route added successfully' : 'Failed to add route',
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add Route'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStopDialog(BuildContext parentContext, Function(BusStop) onStopAdded) {
    final stopNameController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final arrivalTimeController = TextEditingController();
    final orderIndexController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Bus Stop'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: stopNameController,
                  label: 'Stop Name',
                  hint: 'e.g., Main Gate',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stop name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: latitudeController,
                        label: 'Latitude',
                        hint: '0.0000',
                        prefixIcon: Icons.map,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: longitudeController,
                        label: 'Longitude',
                        hint: '0.0000',
                        prefixIcon: Icons.map,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: orderIndexController,
                        label: 'Order',
                        hint: '1',
                        prefixIcon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: arrivalTimeController,
                        label: 'Arrival Time',
                        hint: '08:30 AM',
                        prefixIcon: Icons.access_time,
                      ),
                    ),
                  ],
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final stop = BusStop(
                  name: stopNameController.text.trim(),
                  latitude: double.parse(latitudeController.text),
                  longitude: double.parse(longitudeController.text),
                  orderIndex: int.parse(orderIndexController.text),
                  arrivalTime: arrivalTimeController.text.trim().isEmpty
                      ? null
                      : arrivalTimeController.text.trim(),
                );

                onStopAdded(stop);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditRouteDialog(RouteModel route) {
    final routeNameController = TextEditingController(text: route.routeName);
    final descriptionController = TextEditingController(text: route.description);
    final distanceController = TextEditingController(
      text: route.distance?.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: route.estimatedDuration?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();
    List<BusStop> stops = List.from(route.stops);
    bool isActive = route.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit ${route.routeName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: routeNameController,
                            label: 'Route Name',
                            prefixIcon: Icons.route,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter route name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: descriptionController,
                            label: 'Description',
                            prefixIcon: Icons.description,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: distanceController,
                                  label: 'Distance (km)',
                                  prefixIcon: Icons.straighten,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: durationController,
                                  label: 'Duration (min)',
                                  prefixIcon: Icons.access_time,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Route Active'),
                            subtitle: Text(isActive ? 'Active' : 'Inactive'),
                            value: isActive,
                            onChanged: (value) {
                              setDialogState(() {
                                isActive = value;
                              });
                            },
                            activeColor: AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'Bus Stops',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddStopDialog(context, (stop) {
                                    setDialogState(() {
                                      stops.add(stop);
                                      stops.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
                                    });
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (stops.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No stops added yet',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          else
                            Container(
                              constraints: const BoxConstraints(maxHeight: 250),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ReorderableListView.builder(
                                shrinkWrap: true,
                                itemCount: stops.length,
                                onReorder: (oldIndex, newIndex) {
                                  setDialogState(() {
                                    if (newIndex > oldIndex) newIndex--;
                                    final stop = stops.removeAt(oldIndex);
                                    stops.insert(newIndex, stop);
                                    for (int i = 0; i < stops.length; i++) {
                                      stops[i] = BusStop(
                                        name: stops[i].name,
                                        latitude: stops[i].latitude,
                                        longitude: stops[i].longitude,
                                        orderIndex: i + 1,
                                        arrivalTime: stops[i].arrivalTime,
                                      );
                                    }
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final stop = stops[index];
                                  return ListTile(
                                    key: ValueKey('${stop.name}_$index'),
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                                      radius: 16,
                                      child: Text(
                                        '${stop.orderIndex}',
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      stop.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      stop.arrivalTime ?? 'No time',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: AppColors.error,
                                      onPressed: () {
                                        setDialogState(() {
                                          stops.removeAt(index);
                                          for (int i = 0; i < stops.length; i++) {
                                            stops[i] = BusStop(
                                              name: stops[i].name,
                                              latitude: stops[i].latitude,
                                              longitude: stops[i].longitude,
                                              orderIndex: i + 1,
                                              arrivalTime: stops[i].arrivalTime,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final busProvider = context.read<BusProvider>();

                              final updates = {
                                'routeName': routeNameController.text.trim(),
                                'description': descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                                'distance': distanceController.text.isEmpty
                                    ? null
                                    : double.tryParse(distanceController.text),
                                'estimatedDuration': durationController.text.isEmpty
                                    ? null
                                    : double.tryParse(durationController.text),
                                'isActive': isActive,
                                'stops': stops.map((s) => s.toJson()).toList(),
                              };

                              final success = await busProvider.updateRoute(route.routeId, updates);

                              if (context.mounted) {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success ? 'Route updated successfully' : 'Failed to update route',
                                    ),
                                    backgroundColor: success ? AppColors.success : AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(RouteModel route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete "${route.routeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final busProvider = context.read<BusProvider>();
              final success = await busProvider.deleteRoute(route.routeId);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Route deleted successfully' : 'Failed to delete route',
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

  void _showAssignBusDialog(RouteModel route) {
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
              subtitle: Text('Driver: ${bus.driverName ?? "Not assigned"}'),
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
        title: const Text('Route Management'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search routes...',
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

          // Routes List
          Expanded(
            child: Consumer<BusProvider>(
              builder: (context, busProvider, _) {
                final routes = _searchQuery.isEmpty
                    ? busProvider.routes
                    : busProvider.searchRoutes(_searchQuery);

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
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showEditRouteDialog(route),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showAssignBusDialog(route),
                                    icon: const Icon(Icons.directions_bus, size: 18),
                                    label: const Text('Assign Bus'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(route),
                                  icon: const Icon(Icons.delete),
                                  color: AppColors.error,
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
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
        onPressed: _showAddRouteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Route'),
      ),
    );
  }
}