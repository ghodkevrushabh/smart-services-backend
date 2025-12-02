import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class BookingService {
  Future<bool> createBooking(int providerId, String serviceCategory) async {
    final url = Uri.parse('${AppConstants.baseUrl}/bookings');
    final prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString('jwt_token');
    final myUserId = prefs.getInt('user_id'); // Retrieve my ID

    if (myUserId == null || token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer_id': myUserId, // Me
          'provider_id': providerId, // Ramu
          'service_category': serviceCategory, // "Plumber"
          'scheduled_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(), // Tomorrow
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Booking Error: $e");
      return false;
    }
  }
  // NEW: Fetch my history
  Future<List<dynamic>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final myUserId = prefs.getInt('user_id');

    if (myUserId == null || token == null) return [];

    final url = Uri.parse('${AppConstants.baseUrl}/bookings/user/$myUserId');

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
        return [];
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      return [];
    }
  }
  // NEW: Worker accepts/rejects a job
  Future<bool> updateStatus(int bookingId, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    // We call the generic PATCH endpoint
    final url = Uri.parse('${AppConstants.baseUrl}/bookings/$bookingId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': newStatus, // e.g., "ACCEPTED"
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating status: $e");
      return false;
    }
  }

  // NEW: Customer Rates a Job
  Future<bool> rateJob(int bookingId, int stars, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final url = Uri.parse('${AppConstants.baseUrl}/bookings/$bookingId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'COMPLETED', // Mark as done
          'rating': stars,
          'review_comment': comment
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update User Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userId = prefs.getInt('user_id');

    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId'); // PATCH /users/1

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // NEW: Fetch User Details (For Profile Page)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userId = prefs.getInt('user_id');

    if (userId == null) return null;

    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId');

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
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }
}