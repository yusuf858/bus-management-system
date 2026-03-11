import 'package:flutter/foundation.dart';
import '../core/models/notification_model.dart';
import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _notificationService.initialize();
      _isInitialized = true;
    } catch (e) {
      // Silently handle initialization error
    }
  }

  // Initialize notification stream for user
  void initializeNotificationStream(String userId) {
    _databaseService.getNotificationsStream(userId).listen(
          (notificationsList) {
        _notifications = notificationsList;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading notifications: $error';
        notifyListeners();
      },
    );
  }

  // Add notification
  Future<bool> addNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        data: data,
      );

      await _databaseService.addNotification(userId, notification);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String userId, String notificationId) async {
    try {
      await _databaseService.markNotificationAsRead(userId, notificationId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        await _databaseService.markNotificationAsRead(userId, notification.notificationId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String userId, String notificationId) async {
    try {
      await _databaseService.deleteNotification(userId, notificationId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear all notifications (only database)
  Future<bool> clearAllNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.clearAllNotifications(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _notificationService.getToken();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}