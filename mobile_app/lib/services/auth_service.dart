import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import 'notification_service.dart'; // Import Notification Service

class AuthService {
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // 1. Save Token AND User Details to Phone Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['access_token']);
        await prefs.setInt('user_id', data['user_id']); 
        await prefs.setString('user_role', data['role']); 
        
        // 2. AUTOMATIC TOKEN SYNC (The "Address Book" Update)
        // We immediately tell the server: "This user is on this phone now."
        try {
          final notifService = NotificationService();
          final fcmToken = await notifService.getToken();
          
          if (fcmToken != null) {
            await notifService.uploadToken(fcmToken);
            print("✅ Auto-Sync: Notification Token updated on Login");
          }
        } catch (e) {
          print("⚠️ Auto-Sync Failed (Non-critical): $e");
        }
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
  //Registration Function
  Future<bool> register(String email, String password, String role, String category, String city) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password,
          'role': role,
          'service_category': category,
          'city': city // <--- SENDING CITY NOW
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}