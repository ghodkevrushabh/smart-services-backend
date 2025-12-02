import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ProviderService {
  Future<List<dynamic>> getProvidersByRole(String category, String city) async {
    // 1. Get the URL (e.g., http://192.168.x.x:3000/users/role/WORKER)
    // Note: In a real app, we would filter by 'PLUMBER', but for MVP we fetch all 'WORKERS'
    final url = Uri.parse('${AppConstants.baseUrl}/users/role/WORKER?city=$city&category=$category');
   
    // 2. Get the Token (ID Card)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 3. Convert JSON List to Dart List
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load providers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}