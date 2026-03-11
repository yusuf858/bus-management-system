import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final userId = authProvider.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                if (userId != null) {
                  notificationProvider.markAllAsRead(userId);
                }
              },
            ),
          if (notificationProvider.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                if (userId != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All'),
                      content: const Text('Are you sure you want to clear all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            notificationProvider.clearAllNotifications(userId!);
                            Navigator.pop(context);
                          },
                          child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notificationProvider.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              if (userId != null && !notification.isRead) {
                notificationProvider.markAsRead(userId, notification.notificationId);
              }
            },
            onDelete: () {
              if (userId != null) {
                notificationProvider.deleteNotification(userId, notification.notificationId);
              }
            },
          );
        },
      ),
    );
  }
}