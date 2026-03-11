import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/database_service.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _databaseService = DatabaseService();

  String _sendTo = 'route';
  String? _selectedRouteId;
  String? _selectedBusId;
  String? _selectedRole;
  String _notificationType = 'info';
  bool _isLoading = false;
  bool _sendToAll = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation based on send type
    if (_sendToAll) {
      // No validation needed for send to all
    } else if (_sendTo == 'route' && _selectedRouteId == null) {
      _showError('Please select a route');
      return;
    } else if (_sendTo == 'bus' && _selectedBusId == null) {
      _showError('Please select a bus');
      return;
    } else if (_sendTo == 'role' && _selectedRole == null) {
      _showError('Please select a role');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notification = NotificationModel(
        notificationId: '',
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        timestamp: DateTime.now(),
        type: _notificationType,
      );

      if (_sendToAll) {
        await _databaseService.sendNotificationToAll(notification);
      } else if (_sendTo == 'route') {
        await _databaseService.sendNotificationToRoute(
          _selectedRouteId!,
          notification,
        );
      } else if (_sendTo == 'bus') {
        await _databaseService.sendNotificationToBus(
          _selectedBusId!,
          notification,
        );
      } else if (_sendTo == 'role') {
        await _databaseService.sendNotificationToRole(
          _selectedRole!,
          notification,
        );
      }

      if (mounted) {
        _showSuccess('Notification sent successfully');

        // Clear form
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedRouteId = null;
          _selectedBusId = null;
          _selectedRole = null;
          _sendToAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Send to All checkbox
              Card(
                child: CheckboxListTile(
                  title: const Text(
                    'Send to All Users',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Override other selections'),
                  value: _sendToAll,
                  onChanged: (value) {
                    setState(() {
                      _sendToAll = value ?? false;
                      if (_sendToAll) {
                        _selectedRouteId = null;
                        _selectedBusId = null;
                        _selectedRole = null;
                      }
                    });
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              // Send To Selection
              if (!_sendToAll) ...[
                const Text(
                  'Send To',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Route'),
                      selected: _sendTo == 'route',
                      onSelected: (selected) {
                        setState(() {
                          _sendTo = 'route';
                          _selectedBusId = null;
                          _selectedRole = null;
                        });
                      },
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    ChoiceChip(
                      label: const Text('Bus'),
                      selected: _sendTo == 'bus',
                      onSelected: (selected) {
                        setState(() {
                          _sendTo = 'bus';
                          _selectedRouteId = null;
                          _selectedRole = null;
                        });
                      },
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    ChoiceChip(
                      label: const Text('Role'),
                      selected: _sendTo == 'role',
                      onSelected: (selected) {
                        setState(() {
                          _sendTo = 'role';
                          _selectedRouteId = null;
                          _selectedBusId = null;
                        });
                      },
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Selection Dropdown - FIXED OVERFLOW
                Consumer<BusProvider>(
                  builder: (context, busProvider, _) {
                    if (_sendTo == 'route') {
                      return _buildDropdownField(
                        label: 'Select Route',
                        icon: Icons.route,
                        value: _selectedRouteId,
                        items: busProvider.routes.map((route) {
                          return DropdownMenuItem(
                            value: route.routeId,
                            child: Text(
                              route.routeName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRouteId = value);
                        },
                      );
                    } else if (_sendTo == 'bus') {
                      return _buildDropdownField(
                        label: 'Select Bus',
                        icon: Icons.directions_bus,
                        value: _selectedBusId,
                        items: busProvider.buses.map((bus) {
                          return DropdownMenuItem(
                            value: bus.busId,
                            child: Text(
                              'Bus ${bus.busNumber}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBusId = value);
                        },
                      );
                    } else {
                      return _buildDropdownField(
                        label: 'Select Role',
                        icon: Icons.people,
                        value: _selectedRole,
                        items: const [
                          DropdownMenuItem(value: 'Driver', child: Text('Drivers')),
                          DropdownMenuItem(value: 'Student', child: Text('Students')),
                          DropdownMenuItem(value: 'Admin', child: Text('Admins')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value);
                        },
                      );
                    }
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Notification Type
              _buildDropdownField(
                label: 'Notification Type',
                icon: Icons.category,
                value: _notificationType,
                items: const [
                  DropdownMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20, color: AppColors.info),
                        SizedBox(width: 8),
                        Text('Info'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'alert',
                    child: Row(
                      children: [
                        Icon(Icons.warning, size: 20, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text('Alert'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'update',
                    child: Row(
                      children: [
                        Icon(Icons.update, size: 20, color: AppColors.info),
                        SizedBox(width: 8),
                        Text('Update'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'emergency',
                    child: Row(
                      children: [
                        Icon(Icons.error, size: 20, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Emergency'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _notificationType = value!);
                },
              ),

              const SizedBox(height: 24),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Notification title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Message
              CustomTextField(
                controller: _messageController,
                label: 'Message',
                hint: 'Notification message',
                prefixIcon: Icons.message,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Send Button
              CustomButton(
                text: 'Send Notification',
                onPressed: _sendNotification,
                isLoading: _isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              prefixIcon: Icon(icon, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}