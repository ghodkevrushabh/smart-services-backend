import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import 'dart:convert';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // 1. Initialize (Ask Permission)
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("🔥 FCM TOKEN: $fcmToken");

    // Listen for messages while app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
    });
    
    // Try to upload if already logged in
    if (fcmToken != null) {
      uploadToken(fcmToken);
    }
  }

  // 2. NEW: Dedicated Upload Function
  Future<void> uploadToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final jwt = prefs.getString('jwt_token');

    if (userId != null && jwt != null) {
      final url = Uri.parse('${AppConstants.baseUrl}/users/$userId/token');
      try {
        await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'token': token}),
        );
        print("✅ Token synced with Server for User ID: $userId");
      } catch (e) {
        print("❌ Failed to sync token: $e");
      }
    } else {
      print("⚠️ User not logged in yet. Token stored locally.");
    }
  }
  
  // Helper to get token manually
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}