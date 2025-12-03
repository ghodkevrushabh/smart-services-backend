import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import 'location_service.dart'; // Import Location Service

class ProviderService {
  
  // UPDATED: Now we only need the category (e.g., 'Maid'). 
  // We don't need 'city' because we will get the exact GPS location inside this function.
  Future<List<dynamic>> getProvidersByRole(String category) async {
    
    // 1. Get Current GPS Location
    // This ensures we find providers near where the user is STANDING right now.
    final locData = await LocationService().getCurrentLocation();
    final String lat = locData['lat'].toString();
    final String lng = locData['lng'].toString();
    
    // 2. Build the URL with GPS Coordinates
    // Old: ...?city=Mumbai&category=Maid
    // New: ...?lat=19.12&lng=72.54&category=Maid
    final url = Uri.parse('${AppConstants.baseUrl}/users/role/WORKER?lat=$lat&lng=$lng&category=$category');
   
    // 3. Get the Token
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
        return jsonDecode(response.body);
      } else {
        // If API fails, return empty list instead of crashing
        return [];
      }
    } catch (e) {
      print("Error fetching providers: $e");
      return [];
    }
  }
}