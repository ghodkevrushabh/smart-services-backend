import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get current City and Coordinates
  Future<Map<String, String>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if GPS is on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'city': 'Unknown', 'address': 'Location Disabled'};
    }

    // 2. Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {'city': 'Unknown', 'address': 'Permission Denied'};
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {'city': 'Unknown', 'address': 'Permission Permanently Denied'};
    }

    // 3. Get Coordinates
    Position position = await Geolocator.getCurrentPosition();

    // 4. Convert to Address (Reverse Geocoding)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Priority: Locality (City) -> SubAdminArea (District)
        String city = place.locality ?? place.subAdministrativeArea ?? "Unknown";
        String country = place.country ?? "India";
        
        return {
          'city': city,
          'address': "$city, $country",
          'lat': position.latitude.toString(),
          'lng': position.longitude.toString()
        };
      }
    } catch (e) {
      print("Geocoding Error: $e");
    }

    return {'city': 'Unknown', 'address': 'Unknown Location'};
  }
}