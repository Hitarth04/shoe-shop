import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request Permission
    await _requestPermission();

    // 2. Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Helper to check permission status for Profile Screen
  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // --- SHOW NOTIFICATION (Generic) ---
  Future<void> showOrderNotification(String orderId, String status) async {
    // Customize message based on status
    String title = "Order Update 📦";
    String body = "Your order #$orderId is now $status";

    if (status == 'Delivered') {
      title = "Order Delivered! 🎉";
      body = "Your order #$orderId has arrived. Enjoy your shoes!";
    } else if (status == 'Shipped') {
      title = "Order Shipped 🚚";
      body = "Your order #$orderId is on the way!";
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      details,
    );
  }
}
