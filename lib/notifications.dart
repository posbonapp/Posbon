import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'locale_provider.dart';

final FlutterLocalNotificationsPlugin _local =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {}

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'posbon_channel',
  'Posbon',
  description: 'Posbon notifications',
  importance: Importance.high,
);

class Notifications {
  /// Set when a push notification is tapped (cold start or background).
  /// Root screens listen to this to deep-link to the relevant tab, then
  /// clear it once consumed.
  static final ValueNotifier<String?> pendingType = ValueNotifier<String?>(null);

  static void _handleTap(RemoteMessage message) {
    final type = message.data['type'];
    if (type != null) pendingType.value = type;
  }

  static Future<void> setup() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _local.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) pendingType.value = details.payload;
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;
      await _local.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['type'],
      );
    });

    // Tapped from tray while app was in background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    // App was launched (cold start) by tapping a notification.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);

    // NEW: save token every time someone signs in
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.tokenRefreshed) {
        syncToken();
      }
    });

    await syncToken();
    messaging.onTokenRefresh.listen((t) => _saveToken(t));
  }

  /// Saves the current device token (if any) and the current locale for the
  /// logged in user. Safe to call many times. Locale sync must not depend on
  /// getToken() succeeding — no push permission / iOS simulator / no Play
  /// Services all leave token null, and language sync still has to go through.
  static Future<void> syncToken() async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('PUSH: getToken failed -> $e');
    }
    await _saveToken(token);
  }

  static Future<void> _saveToken(String? token) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('PUSH: no user yet, token/locale not saved');
      return;
    }
    try {
      await supabase.rpc('save_device_token', params: {
        'p_token': token,
        'p_locale': localeProvider.effectiveCode,
      });
      debugPrint('PUSH: synced for ${user.id} (token: ${token != null})');
    } catch (e) {
      debugPrint('PUSH: save failed -> $e');
    }
  }

  static Future<void> removeToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    try {
      await supabase.from('device_tokens').delete().eq('token', token);
    } catch (e) {
      debugPrint('PUSH: remove failed -> $e');
    }
  }
}