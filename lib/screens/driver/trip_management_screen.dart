import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/bus_model.dart';
import '../../providers/bus_provider.dart';

class TripManagementScreen extends StatefulWidget {
  final BusModel bus;

  const TripManagementScreen({super.key, required this.bus});

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen> {
  bool _isTripActive = false;
  DateTime? _tripStartTime;

  void _startTrip() async {
    final busProvider = context.read<BusProvider>();

    final success = await busProvider.updateBus(widget.bus.busId, {
      'isActive': true,
      'status': 'On Route',
    });

    if (success && mounted) {
      setState(() {
        _isTripActive = true;
        _tripStartTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip started successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _endTrip() async {
    final busProvider = context.read<BusProvider>();

    final success = await busProvider.updateBus(widget.bus.busId, {
      'isActive': false,
      'status': 'Idle',
    });

    if (success && mounted) {
      setState(() {
        _isTripActive = false;
        _tripStartTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip ended successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select the type of issue:'),
            // Add issue reporting options here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reported to admin'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bus Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isTripActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_bus,
                            color: _isTripActive
                                ? AppColors.success
                                : AppColors.primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bus ${widget.bus.busNumber}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.bus.routeName ?? 'No route assigned',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isTripActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isTripActive ? 'Active' : 'Idle',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isTripActive
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trip Status
            if (_isTripActive && _tripStartTime != null) ...[
              Card(
                color: AppColors.success.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'Trip in Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Started at: ${_tripStartTime!.hour.toString().padLeft(2, '0')}:${_tripStartTime!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (!_isTripActive)
              ElevatedButton.icon(
                onPressed: _startTrip,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 56),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _endTrip,
                icon: const Icon(Icons.stop),
                label: const Text('End Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _reportIssue,
              icon: const Icon(Icons.report_problem),
              label: const Text('Report Issue'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),

            const SizedBox(height: 32),

            // Info Section
            const Text(
              'Important Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.check_circle_outline,
                      text: 'Ensure all students are seated before starting',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.check_circle_outline,
                      text: 'Follow the designated route',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.check_circle_outline,
                      text: 'Report any issues immediately',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.check_circle_outline,
                      text: 'GPS tracking is automatic via WheelsEye',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}