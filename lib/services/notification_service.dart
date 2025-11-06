import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Callback for notification tap
  static Function(String)? onNotificationTap;

  /// Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          onNotificationTap?.call(payload);
        }
      },
    );

    // ✅ Create a notification channel with high importance
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'analysis_channel',
      'Analysis Notifications',
      description: 'Notifications for analysis results',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  /// ✅ Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) return true;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// ✅ Show an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'analysis_channel',
      'Analysis Notifications',
      channelDescription: 'Notifications for analysis results',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Optional: daily reminder notification
  Future<void> showDailyReminder() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Reminders to use the app',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await notificationsPlugin.periodicallyShow(
      0,
      '🔍 Smart Vision Analyzer',
      'Discover new features in your image analysis app!',
      RepeatInterval.daily,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelDailyReminder() async => await notificationsPlugin.cancel(0);
  Future<void> cancelAllNotifications() async =>
      await notificationsPlugin.cancelAll();
}
