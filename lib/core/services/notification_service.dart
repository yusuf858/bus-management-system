import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_service.dart';

// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  // Initialize notification service
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get and save FCM token
    await _getFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then(_handleNotificationOpen);

    // Handle notification opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Handle token refresh
    _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  // Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      String? token = await _fcm.getToken();

      // Save token to database
      if (token != null && _authService.currentUser != null) {
        await _authService.updateFCMToken(_authService.currentUser!.uid, token);
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  // Handle token refresh
  Future<void> _onTokenRefresh(String token) async {
    if (_authService.currentUser != null) {
      await _authService.updateFCMToken(_authService.currentUser!.uid, token);
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      // Notification will be shown automatically by Firebase
      // You can add custom logic here if needed
    }
  }

  // Handle notification opened
  void _handleNotificationOpen(RemoteMessage? message) {
    if (message != null) {
      _handleNotificationData(message.data);
    }
  }

  // Handle notification data
  void _handleNotificationData(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    // This can be extended to navigate to specific screens

    if (data.containsKey('screen')) {
      // Navigate to specific screen
      // Example: navigatorKey.currentState?.pushNamed(data['screen']);
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      // Handle error silently
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get FCM token (public method)
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
    } catch (e) {
      // Handle error silently
    }
  }
}