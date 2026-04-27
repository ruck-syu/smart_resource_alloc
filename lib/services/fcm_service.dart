import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase Cloud Messaging service for push notifications.
///
/// Currently in **mock/scaffold mode** — all FCM logic is ready to be
/// uncommented once `firebase_messaging` is configured in the project.
class FcmService {
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM and retrieve the device token.
  Future<String?> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permission (important for iOS)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Get FCM token
      _fcmToken = await messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        // TODO: Update token on backend via PUT /volunteers/:id
      });
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message: ${message.notification?.title}');
        _handleNotification(message.data);
      });
      
      // Handle background/terminated tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tap: ${message.data}');
        _handleNotificationTap(message.data);
      });
      
      // Check if app was opened from a terminated state notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage.data);
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('FCM initialization failed (falling back to mock): $e');
      // Mock mode — generate a fake token
      _fcmToken = 'mock-fcm-token-${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('FCM Mock Token: $_fcmToken');
      return _fcmToken;
    }
  }

  /// Handle incoming notification data payload.
  /// Expected shape:
  /// ```json
  /// {
  ///   "taskId": "task-uuid",
  ///   "needId": "need-uuid",
  ///   "type": "task_assigned"
  /// }
  /// ```
  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'];
    final taskId = data['taskId'];
    debugPrint('Notification received — type: $type, taskId: $taskId');
    // Show in-app notification or update local state
  }

  /// Handle notification tap — navigate to relevant screen.
  void _handleNotificationTap(Map<String, dynamic> data) {
    final taskId = data['taskId'];
    if (taskId != null) {
      // Navigate to task detail page
      // Can use a global navigator key or a callback pattern
      debugPrint('Should navigate to task: $taskId');
    }
  }
}
